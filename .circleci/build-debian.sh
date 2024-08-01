#!/usr/bin/env bash

#
# Build for Debian in a docker container
#

# bailout on errors and echo commands.
set -xe

DOCKER_SOCK="unix:///var/run/docker.sock"

echo "DOCKER_OPTS=\"-H tcp://127.0.0.1:2375 -H $DOCKER_SOCK -s overlay2\"" | sudo tee /etc/default/docker > /dev/null
sudo service docker restart
sleep 5;

WORK_DIR=$(pwd):/ci-source

docker run --privileged --cap-add=ALL --security-opt="seccomp=unconfined" -d -ti -e "container=docker"  -v $WORK_DIR:rw $DOCKER_IMAGE /bin/bash
DOCKER_CONTAINER_ID=$(docker ps --last 4 | grep $CONTAINER_DISTRO | awk '{print $1}')

docker exec --privileged -ti $DOCKER_CONTAINER_ID apt-get update
docker exec --privileged -ti $DOCKER_CONTAINER_ID apt-get -y install apt-transport-https wget curl gnupg2
docker exec --privileged -ti $DOCKER_CONTAINER_ID apt-get -y install dpkg-dev debhelper devscripts equivs pkg-config apt-utils fakeroot clang cmake ninja-build \
  libgtk-3-dev libgtk-3-0 libblkid1 liblzma5 liblzma-dev libstdc++-12-dev 

docker exec --privileged -ti "$DOCKER_CONTAINER_ID" /bin/bash -xec \
  "cd ci-source/.circleci; chmod -v u+w *.sh; /bin/bash -xe ./flutter-build.sh $PKG_ARCH"

echo "Stopping"
docker ps -a
docker stop $DOCKER_CONTAINER_ID
docker rm -v $DOCKER_CONTAINER_ID
