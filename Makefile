build.docker: build.intercept.docker build.collector.docker

build.intercept:
	cd intercept && cargo build --target wasm32-unknown-unknown --release

build.record.sidecar:build.intercept
	cp ./envoy/envoy ./record-sidecar/docker/data/envoy
	cp ./intercept/target/wasm32-unknown-unknown/release/intercept.wasm ./record-sidecar/docker/data/intercept.wasm
	cp ./record-sidecar/envoy.yaml ./record-sidecar/docker/data/envoy.yaml
	cd ./record-sidecar/docker && nerdctl build -t mockest/intercept .

build.collector:
	cd collector && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./target/collector
build.collector.docker:build.collector
	cp ./collector/target/collector ./collector/docker
	cd ./collector/docker && nerdctl build -t mockest/collector .

test.sandbox:
	nerdctl network create mockest
	nerdctl run -d --cap-add=NET_ADMIN --cap-add=NET_RAW  --network mockest --name intercept  mockest/intercept
	nerdctl run -d --network mockest --name collector  mockest/collector
test.sandbox.clean:
	nerdctl network rm mockest
	nerdctl rm -f `nerdctl ps -qa`