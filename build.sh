#!/bin/bash

currdir=$PWD
(cd external/su-exec; make; mv su-exec $currdir; make clean)

DOCKER_IMG_NAME="docker-intellij-idea"
TAG="2021.2"

docker build --compress -t ${DOCKER_IMG_NAME}:${TAG} .

rm -f su-exec
