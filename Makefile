# Define variables
VERSION := 1.3.1
OS := $(shell uname -s | tr A-Z a-z)
ARCH := $(shell uname -m | sed 's/x86_64/amd64/')

# Define the installation directory
NODE_EXPORTER_DIR := $(HOME)/node_exporter

# todo following two are duplicates

.PHONY: build
build:
	go build main.go

scripts/benchmark:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o scripts/benchmark main.go

.PHONY: install-tools
install-tools:
	@echo Installing tools from tools.go
	@go list -e -f '{{ join .Imports "\n" }}' tools.go | xargs -I % go list -f "%@{{.Module.Version}}" % | xargs -tI % go install %
	@go mod tidy

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

.PHONY: fmt
fmt:
	gofumpt -l -w .

.PHONY: lint
lint:
	golangci-lint run -v

.PHONY: install-node-exporter
install-node-exporter:
	@if [ -f "$(NODE_EXPORTER_DIR)/node_exporter" ]; then \
		echo "node_exporter is already installed."; \
	else \
		echo "Installing node_exporter..."; \
		curl -sSL -o node_exporter-$(VERSION).$(OS)-$(ARCH).tar.gz \
			https://github.com/prometheus/node_exporter/releases/download/v$(VERSION)/node_exporter-$(VERSION).$(OS)-$(ARCH).tar.gz || \
			{ echo "curl download failed, installation aborted."; exit 1; }; \
		tar xvfz node_exporter-*.$(OS)-$(ARCH).tar.gz; \
		mkdir -p $(NODE_EXPORTER_DIR); \
		mv node_exporter-$(VERSION).$(OS)-$(ARCH)/node_exporter $(NODE_EXPORTER_DIR)/; \
		rm -rf node_exporter-*.$(OS)-$(ARCH).tar.gz node_exporter-$(VERSION).$(OS)-$(ARCH); \
		echo "node_exporter has been installed to $(NODE_EXPORTER_DIR)"; \
	fi

.PHONY: run-node-exporter
run-node-exporter:
	@if [ -f "$(NODE_EXPORTER_DIR)/node_exporter" ]; then \
		$(NODE_EXPORTER_DIR)/node_exporter; \
	else \
		echo "node_exporter is not installed. Please run 'make install-node-exporter' first."; \
	fi
