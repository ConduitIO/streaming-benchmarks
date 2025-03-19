VERSION=`go list -e -f '{{.Module.Version}}' github.com/conduitio/conduit`

.PHONY: build
build:
	go build -ldflags "-X 'github.com/conduitio/conduit/pkg/conduit.version=${VERSION}'" -o conduit main.go
