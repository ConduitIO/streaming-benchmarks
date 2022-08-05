// Copyright © 2022 Meroxa, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"errors"
	"flag"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/charmbracelet/glamour"
	"github.com/docker/go-units"
	"github.com/gocarina/gocsv"
	promclient "github.com/prometheus/client_model/go"
	"github.com/prometheus/common/expfmt"
)

const pipelineName = "perf-test"

type Metrics struct {
	Count         uint64
	Bytes         float64
	MeasuredAt    time.Time
	RecordsPerSec float64
	MsPerRec      float64
	PipelineRate  uint64
	BytesPerSec   string

	// Processor related
	Goroutines uint64
	Threads    uint64

	// Memory related
	MemstatsAllocBytes      uint64
	MemstatsAllocBytesTotal uint64
	MemstatsStackInUseBytes uint64
	MemstatsHeapInUseBytes  uint64
}

func (m Metrics) msPerRecStr() string {
	return strconv.FormatFloat(m.MsPerRec, 'f', 10, 64)
}

var printerTypes = []string{"csv", "console"}

type printer interface {
	init() error
	print(Metrics) error
	close() error
}

func newPrinter(printerType string, workload string) (printer, error) {
	var p printer
	switch printerType {
	case "console":
		p = &consolePrinter{workload: workload}
	case "csv":
		p = &csvPrinter{workload: workload}
	default:
		return nil, fmt.Errorf("unknown printer type %q, possible values: %v", printerType, printerTypes)
	}
	err := p.init()
	if err != nil {
		return nil, fmt.Errorf("failed initializing printer: %w", err)
	}
	return p, nil
}

type csvPrinter struct {
	workload string
	file     *os.File
}

func (c *csvPrinter) init() error {
	file, err := os.Create(
		fmt.Sprintf("./performance-test-results-%v.csv", time.Now().Format("2006-01-02-15-04-05")),
	)
	if err != nil {
		return fmt.Errorf("failed creating file: %w", err)
	}
	c.file = file
	str, err := gocsv.MarshalString([]Metrics{})
	if err != nil {
		return err
	}
	_, err = c.file.WriteString(str)
	return err
}

func (c *csvPrinter) print(m Metrics) error {
	str, err := gocsv.MarshalStringWithoutHeaders([]Metrics{m})
	if err != nil {
		return err
	}
	_, err = c.file.WriteString(str)
	return err
}

func (c *csvPrinter) close() error {
	return c.file.Close()
}

type consolePrinter struct {
	renderer *glamour.TermRenderer
	workload string
}

func (c *consolePrinter) init() error {
	r, _ := glamour.NewTermRenderer(
		// detect background color and pick either the default dark or light theme
		glamour.WithAutoStyle(),
		glamour.WithWordWrap(200),
	)
	c.renderer = r
	return nil
}

func (c *consolePrinter) print(m Metrics) error {
	in := `
| workload | total records | rec/s (Conduit) | ms/record (Conduit) | rec/s (pipeline) | bytes/s | measured at |
|----------|---------------|-----------------|---------------------|------------------|---------|-------------|
| %v       | %v            | %v              | %v                  | %v               | %v      | %v          |


`
	in = fmt.Sprintf(
		in,
		c.workload,
		m.Count,
		m.RecordsPerSec,
		m.msPerRecStr(),
		m.PipelineRate,
		m.BytesPerSec,
		m.MeasuredAt.Format(time.RFC3339),
	)
	out, err := c.renderer.Render(in)
	if err != nil {
		return fmt.Errorf("failed rendering output: %w", err)
	}
	fmt.Print(out)
	return nil
}

func (c *consolePrinter) close() error {
	return nil
}

type collector struct {
	first Metrics
}

func newCollector() (collector, error) {
	c := collector{}
	err := c.init()
	if err != nil {
		return collector{}, fmt.Errorf("failed initializing collector: %w", err)
	}
	return c, err
}

func (c *collector) init() error {
	first, err := c.collect()
	if err != nil {
		return err
	}
	c.first = first
	return nil
}

func (c *collector) collect() (Metrics, error) {
	metricFamilies, err := c.getMetrics()
	if err != nil {
		return Metrics{}, fmt.Errorf("failed getting Metrics: %v", err)
	}

	m := Metrics{}
	count, totalTime, err := c.getPipelineMetrics(metricFamilies)
	if err != nil {
		fmt.Printf("failed getting pipeline Metrics: %v", err)
		os.Exit(1)
	}
	m.Count = count
	m.RecordsPerSec = float64(count) / totalTime
	m.MsPerRec = (totalTime / float64(count)) * 1000
	m.Bytes = c.getSourceByteMetrics(metricFamilies)
	m.BytesPerSec = units.HumanSize(m.Bytes / totalTime)
	m.PipelineRate = (count - c.first.Count) / uint64(time.Since(c.first.MeasuredAt).Seconds())
	m.MeasuredAt = time.Now()

	return m, nil
}

// getMetrics returns all the metrics which Conduit exposes
func (c *collector) getMetrics() (map[string]*promclient.MetricFamily, error) {
	metrics, err := http.Get("http://localhost:8080/metrics")
	if err != nil {
		fmt.Printf("failed getting Metrics: %v", err)
		os.Exit(1)
	}
	defer metrics.Body.Close()

	var parser expfmt.TextParser
	return parser.TextToMetricFamilies(metrics.Body)
}

// getPipelineMetrics extract the test pipeline's metrics
// (total number of records, time records spent in pipeline)
func (c *collector) getPipelineMetrics(families map[string]*promclient.MetricFamily) (uint64, float64, error) {
	family, ok := families["conduit_pipeline_execution_duration_seconds"]
	if !ok {
		return 0, 0, errors.New("metric family conduit_pipeline_execution_duration_seconds not available")
	}

	for _, m := range family.Metric {
		if c.hasLabel(m, "pipeline_name", pipelineName) {
			return *m.Histogram.SampleCount, *m.Histogram.SampleSum, nil
		}
	}

	return 0, 0, fmt.Errorf("Metrics for pipeline %q not found", pipelineName)
}

// getSourceByteMetrics returns the amount of bytes the sources in the test pipeline produced
func (c *collector) getSourceByteMetrics(families map[string]*promclient.MetricFamily) float64 {
	for _, m := range families["conduit_connector_bytes"].Metric {
		if c.hasLabel(m, "pipeline_name", pipelineName) && c.hasLabel(m, "type", "source") {
			return *m.Histogram.SampleSum
		}
	}

	return 0
}

// hasLabel returns true, if the input metrics has a label with the given name and value
func (c *collector) hasLabel(m *promclient.Metric, name string, value string) bool {
	for _, labelPair := range m.GetLabel() {
		if labelPair.GetName() == name && labelPair.GetValue() == value {
			return true
		}
	}
	return false
}

func main() {
	interval := flag.Duration(
		"interval",
		5*time.Minute,
		"interval at which the current performance results will be collected and printed.",
	)
	duration := flag.Duration(
		"duration",
		5*time.Minute,
		"duration for which the Metrics will be collected and printed",
	)
	printTo := flag.String(
		"print-to",
		"csv",
		"where the Metrics will be printed ('csv' to print to a CSV file, or 'console' to print to console",
	)
	workload := flag.String(
		"workload",
		"",
		"workload script",
	)
	flag.Parse()

	until := time.Now().Add(*duration)
	c, err := newCollector()
	if err != nil {
		fmt.Printf("couldn't create collector: %v", err)
		os.Exit(1)
	}

	p, err := newPrinter(*printTo, *workload)
	if err != nil {
		fmt.Printf("couldn't create printer: %v", err)
		os.Exit(1)
	}

	for {
		time.Sleep(*interval)
		metrics, err := c.collect()
		if err != nil {
			fmt.Printf("couldn't collect metrics: %v", err)
			os.Exit(1)
		}
		err = p.print(metrics)
		if err != nil {
			fmt.Printf("couldn't print metrics: %v", err)
			os.Exit(1)
		}
		if time.Now().After(until) {
			break
		}
	}
	p.close()
}
