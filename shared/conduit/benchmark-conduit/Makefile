VERSION=$(shell go list -e -m -f '{{.Version}}' github.com/conduitio/conduit)

.PHONY: build
build:
	echo "Conduit version is ${VERSION}"
	go build -ldflags "-X 'github.com/conduitio/conduit/pkg/conduit.version=${VERSION}'" -o conduit main.go
