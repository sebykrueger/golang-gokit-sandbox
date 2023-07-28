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
declare -r project_version="${PROJECT_VERSION:-1.0.0-alpha}"

echo "Building image '$DOCKER_IMAGE_NAME:$DOCKER_IMAGE_TAG'..."
# TIP: Add `--progress=plain` to see the full docker output when you are
# troubleshooting the build setup of your image.
declare -r DOCKER_OPTIONS=""
# Use BuildKit, i.e. `buildx build` instead of just `build`
# https://docs.docker.com/build/
docker buildx build $DOCKER_OPTIONS \
    --build-arg PROJECT_VERSION=${project_version} \
    --build-arg DOCKER_org_opencontainers_image_authors="${DOCKER_org_opencontainers_image_authors}" \
    --build-arg DOCKER_org_opencontainers_image_url="${DOCKER_org_opencontainers_image_url}" \
    --build-arg DOCKER_org_opencontainers_image_vendor="${DOCKER_org_opencontainers_image_vendor}" \
    --build-arg DOCKER_org_opencontainers_image_licenses="${DOCKER_org_opencontainers_image_licenses}" \
    --build-arg DOCKER_org_opencontainers_image_ref_name="${DOCKER_org_opencontainers_image_ref_name}" \
    --build-arg DOCKER_org_opencontainers_image_title="${DOCKER_org_opencontainers_image_title}" \
    --build-arg DOCKER_org_opencontainers_image_description="${DOCKER_org_opencontainers_image_description}" \
    --build-arg GIT_COMMIT=$(git rev-parse -q --verify HEAD) \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --tag "$DOCKER_IMAGE_NAME":"$DOCKER_IMAGE_TAG" .

    