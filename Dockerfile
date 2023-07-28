# We use a multi-stage build setup.
# (https://docs.docker.com/build/building/multi-stage/)

# Stage 1 (to create a "build" image, ~850MB)
FROM golang:1.20.5 AS builder
# smoke test to verify if golang is available
RUN go version

# Update
RUN apt-get --allow-releaseinfo-change update && apt upgrade -y

COPY . /build
WORKDIR /build

# Fetch dependencies
RUN set -Eeux && \
    go mod download all && \
    go mod verify

# Build image as a truly static Go binary
RUN CGO_ENABLED=0 GOOS=linux \
    go build \
    -o /main \
    -trimpath \
    -a -tags netgo \
    -ldflags '-s -w' .

# RUN GOOS=linux GOARCH=amd64 \
#     go build \
#     -trimpath \
#     -ldflags="-w -s -X 'main.Version=${PROJECT_VERSION}'" \
#     -o app cmd/golang-docker-build-tutorial/main.go
# RUN go test -cover -v ./...

