#!/bin/bash
IMAGE=portainer/portainer
TAG=1.16.4
REGISTRY=registry.services.alin.be

docker pull $IMAGE:$TAG
docker tag $IMAGE:$TAG $REGISTRY/$IMAGE:v1
docker push $REGISTRY/$IMAGE:v1
docker rmi $IMAGE:$TAG

docker images | grep $IMAGE
