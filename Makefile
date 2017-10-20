GIT_VER := $(shell git describe --tags)
DATE := $(shell date +%Y-%m-%dT%H:%M:%S%z)

.PHONY: test local get-deps packages install clean

cmd/kinesis-tailf/kinesis-tailf: *.go cmd/kinesis-tailf/*.go
	cd cmd/kinesis-tailf && go build -ldflags "-s -w -X main.version=${GIT_VER} -X main.buildDate=${DATE}" -gcflags="-trimpath=${PWD}"

install: cmd/kinesis-tailf/kinesis-tailf
	install cmd/kinesis-tailf/kinesis-tailf ${GOPATH}/bin

test:
	go test -race ./...

get-dep-amd64:
	wget -O ${GOPATH}/bin/dep https://github.com/golang/dep/releases/download/v0.3.2/dep-linux-amd64
	chmod +x ${GOPATH}/bin/dep

get-deps:
	dep ensure

packages:
	cd cmd/kinesis-tailf && gox -os="linux darwin" -arch="amd64" -output "../../pkg/{{.Dir}}-${GIT_VER}-{{.OS}}-{{.Arch}}" -ldflags "-w -s -X main.version=${GIT_VER} -X main.buildDate=${DATE}"
	cd pkg && find . -name "*${GIT_VER}*" -type f -exec zip {}.zip {} \;

clean:
	rm -f cmd/kinesis-tailf/kinesis-tailf
	rm -f pkg/*
