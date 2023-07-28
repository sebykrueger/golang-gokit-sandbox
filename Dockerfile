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

# Image And Container Label Metadata
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
# ARG PROJECT_VERSION
# ARG DOCKER_org_opencontainers_image_authors
# ARG DOCKER_org_opencontainers_image_url
# ARG DOCKER_org_opencontainers_image_vendor
# ARG DOCKER_org_opencontainers_image_licenses
# ARG DOCKER_org_opencontainers_image_ref_name
# ARG DOCKER_org_opencontainers_image_title
# ARG DOCKER_org_opencontainers_image_description

# LABEL maintainer="${DOCKER_org_opencontainers_image_authors}" \
#     org.opencontainers.image.authors="${DOCKER_org_opencontainers_image_authors}" \
#     org.opencontainers.image.url="${DOCKER_org_opencontainers_image_url}" \
#     org.opencontainers.image.version="${PROJECT_VERSION}" \
#     org.opencontainers.image.vendor="${DOCKER_org_opencontainers_image_vendor}" \
#     org.opencontainers.image.licenses="${DOCKER_org_opencontainers_image_licenses}" \
#     org.opencontainers.image.ref.name="${DOCKER_org_opencontainers_image_ref_name}" \
#     org.opencontainers.image.title="${DOCKER_org_opencontainers_image_title}" \
#     org.opencontainers.image.description="${DOCKER_org_opencontainers_image_description}"

# ARG GIT_COMMIT
# LABEL org.opencontainers.image.revision "${GIT_COMMIT}"

# ARG BUILD_DATE
# LABEL org.opencontainers.image.created "${BUILD_DATE}"

COPY --from=builder /app .
EXPOSE 8080
ENTRYPOINT ["./app"]
