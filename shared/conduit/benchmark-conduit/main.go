// Copyright © 2025 Meroxa, Inc.
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
	chaos "github.com/conduitio-labs/conduit-connector-chaos"
	mongo "github.com/conduitio-labs/conduit-connector-mongo"
	mysql "github.com/conduitio-labs/conduit-connector-mysql"
	snowflake "github.com/conduitio-labs/conduit-connector-snowflake"
	"github.com/conduitio/conduit/cmd/conduit/cli"
	"github.com/conduitio/conduit/pkg/conduit"
)

func main() {
	// Get the default configuration, including all built-in connectors
	cfg := conduit.DefaultConfig()

	cfg.ConnectorPlugins["mongo"] = mongo.Connector
	cfg.ConnectorPlugins["chaos"] = chaos.Connector
	cfg.ConnectorPlugins["mysql"] = mysql.Connector
	cfg.ConnectorPlugins["snowflake"] = snowflake.Connector

	cli.Run(cfg)
}
