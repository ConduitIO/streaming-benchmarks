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
	"context"

	sdk "github.com/conduitio/conduit-connector-sdk"
)

func main() {
	sdk.Serve(sdk.Connector{
		NewSpecification: Spec,
		NewSource:        nil,
		NewDestination:   NewDestination,
	})
}

func Spec() sdk.Specification {
	return sdk.Specification{
		Name:        "noop-dest",
		Summary:     "A NoOp destination connector.",
		Description: "A NoOp destination connector.",
		Version:     "v0.1.0",
		Author:      "Meroxa, Inc.",
	}
}

type destination struct {
	sdk.UnimplementedDestination
}

func NewDestination() sdk.Destination {
	return destination{}
}

func (d destination) Parameters() map[string]sdk.Parameter {
	return map[string]sdk.Parameter{}
}

func (d destination) Configure(_ context.Context, _ map[string]string) error {
	return nil
}

func (d destination) Open(ctx context.Context) error {
	return nil
}

func (d destination) Write(ctx context.Context, r []sdk.Record) (n int, err error) {
	return len(r), nil
}

func (d destination) Teardown(_ context.Context) error {
	return nil
}
