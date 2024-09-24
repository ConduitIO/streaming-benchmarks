.PHONY: build-local build-noop-dest run-local run-latest run-latest-nightly print-results

.PHONY: build
build:
	go build main.go

scripts/benchmark:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o scripts/benchmark main.go

# Builds a fresh Docker image, so we're not limited on the GA and nightly builds
.PHONY: build-local
build-local:
	@cd ../conduit && docker build -t conduit:local .

.PHONY: run-local
run-local: scripts/benchmark
	scripts/run-docker-all.sh conduit:local

.PHONY: run-latest
run-latest: scripts/benchmark
	docker pull ghcr.io/conduitio/conduit:latest
	scripts/run-docker-all.sh ghcr.io/conduitio/conduit:latest

.PHONY: run-latest-nightly
run-latest-nightly: scripts/benchmark
	docker pull ghcr.io/conduitio/conduit:latest-nightly
	scripts/run-docker-all.sh ghcr.io/conduitio/conduit:latest-nightly

.PHONY: lint
lint:
	golangci-lint run
