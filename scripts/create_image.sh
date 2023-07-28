#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# `-u`: Errors if a variable is referenced before being set
# `-o pipefail`: Prevent errors in a pipeline (`|`) from being masked
set -uo pipefail

# cd into the bundle and use relative paths
if [[ $BASH_SOURCE = */* ]]; then
    cd -- "${BASH_SOURCE%/*}/"
    cd ..
fi

# Import environment variables from .env
set -o allexport && source .env && set +o allexport

# Set variable from environment variable PROJECT_VERSION, if the latter exists.
# If not, fall back to the specified default value (excluding the leading `-`).
declare -r build_version="${BUILD_VERSION:-1.0.0-alpha}"

echo "Building image '$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'..."
# TIP: Add `--progress=plain` to see the full docker output when you are
# troubleshooting the build setup of your image.
declare -r DOCKER_OPTIONS=""
# Use BuildKit, i.e. `buildx build` instead of just `build`
# https://docs.docker.com/build/
# Image And Container Label Metadata
# https://github.com/opencontainers/image-spec/blob/main/annotations.md
docker buildx build $DOCKER_OPTIONS \
    --build-arg BUILD_VERSION=${build_version} \
    --label org.opencontainers.image.authors="${DOCKER_org_opencontainers_image_authors}" \
    --label org.opencontainers.image.source="${DOCKER_org_opencontainers_image_url}" \
    --label org.opencontainers.image.url="${DOCKER_org_opencontainers_image_url}" \
    --label org.opencontainers.image.vendor="${DOCKER_org_opencontainers_image_vendor}" \
    --label org.opencontainers.image.licenses="${DOCKER_org_opencontainers_image_licenses}" \
    --label org.opencontainers.image.title="${DOCKER_org_opencontainers_image_title}" \
    --label org.opencontainers.image.description="${DOCKER_org_opencontainers_image_description}" \
    --label org.opencontainers.image.revision=$(git rev-parse -q --verify HEAD) \
    --label org.opencontainers.image.created=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --label org.opencontainers.image.version=${build_version} \
    --tag "$DOCKER_IMAGE_NAME":"$DOCKER_IMAGE_TAG" .