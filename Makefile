.PHONY: build-local build-noop-dest run-local run-latest run-latest-nightly print-results

build:
	go build main.go

scripts/benchmark:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o scripts/benchmark main.go

# Builds a fresh Docker image, so we're not limited on the GA and nightly builds
build-local:
	@cd ../conduit && docker build -t conduit:local .

plugins/noop-dest:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o plugins/noop-dest noopdest/main.go

run-local: plugins/noop-dest
	scripts/run-docker-all.sh conduit:local

run-latest: plugins/conduit-connector-noop-dest
	docker pull ghcr.io/conduitio/conduit:latest
	scripts/run-docker-all.sh ghcr.io/conduitio/conduit:latest

run-latest-nightly: plugins/conduit-connector-noop-dest
	docker pull ghcr.io/conduitio/conduit:latest-nightly
	scripts/run-docker-all.sh ghcr.io/conduitio/conduit:latest-nightly

lint:
	golangci-lint run
