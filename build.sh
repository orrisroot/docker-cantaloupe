#!/bin/bash

set -euo pipefail

IMAGE=orrisroot/cantaloupe
DIR=$(cd "$(dirname "$0")" && pwd)
# Read the version from ARG CANTALOUPE_VERSION in Dockerfile (updated by Renovate)
VERSION=$(sed -n 's/^ARG CANTALOUPE_VERSION=//p' "${DIR}/Dockerfile")

if ! [[ "${VERSION}" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
    echo "Invalid CANTALOUPE_VERSION in Dockerfile: '${VERSION}'" 1>&2
    exit 1
fi

if ! docker build --force-rm -t "${IMAGE}:latest" "${DIR}"; then
    echo "Build error occured." 1>&2
    exit 1
fi
docker image tag "${IMAGE}:latest" "${IMAGE}:${VERSION}"

echo ""
echo "Done! Built ${IMAGE}:latest and ${IMAGE}:${VERSION}."
