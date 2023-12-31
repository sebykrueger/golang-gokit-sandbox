# We use a multi-stage build setup.
# (https://docs.docker.com/build/building/multi-stage/)

# Stage 1 (to create a "build" image, ~850MB)
FROM golang:1.20.5 AS builder
# smoke test to verify if golang is available
RUN go version

# Update
RUN apt-get --allow-releaseinfo-change update && apt upgrade -y

WORKDIR /build

COPY ./go.mod  go.mod
COPY ./go.sum  go.sum
COPY ./main.go main.go
COPY ./service service


# Fetch dependencies
RUN set -Eeux && \
    go mod download && \
    # go mod download all && \
    go mod verify

ARG BUILD_VERSION
# Build image as a truly static Go binary
RUN CGO_ENABLED=0 GOOS=linux \
    go build \
    -o /app \
    -trimpath \
    -a -tags netgo \
    -ldflags="-w -s -X 'main.Version=${BUILD_VERSION}'" .
RUN go test -cover -v ./...

# Stage 2 (to create a downsized "container executable", ~5MB)
FROM scratch
COPY --from=builder /app .
EXPOSE 8080
ENTRYPOINT ["./app"]
