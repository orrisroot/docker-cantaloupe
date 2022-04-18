#!/bin/bash

IMAGE=orrisroot/cantaloupe
REGISTORY=docker.io/${IMAGE}
VERSION=5.0.5

docker build --pull --force-rm --build-arg CANTALOUPE_VERSION=${VERSION} -t ${IMAGE}:latest .
if [ $? -ne 0 ]; then
    echo "Build error occured."
    exit 1
fi
IMAGE_ID=$(docker image ls orrisroot/cantaloupe:latest -q)
docker image tag ${IMAGE_ID} ${IMAGE}:${VERSION}

#docker login
echo ""
echo "Done! To push built images, run the following command."
echo "docker image push --all-tags ${IMAGE}"
