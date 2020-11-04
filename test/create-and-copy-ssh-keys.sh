#!/bin/bash

# Create SSH keys for rsync file transfers.  This file has to be run once the
# Docker containers are running via `docker-compose up` or via
# `./container-compose up`.

# Detect supported container management tool.

if [ -x "$(command -v docker)" ]; then
  CONTAINER_CMD=docker
elif [ -x "$(command -v podman)" ]; then
  CONTAINER_CMD=podman
else
  echo "ERROR: Cannot find 'docker' or 'podman'."
  exit 1
fi

# Detect Master and Worker containers.

BUILDBOT_MASTER=$($CONTAINER_CMD ps -a | grep -o [^[:blank:]]*buildbot-master[^[:blank:]]*)
BUILDBOT_WORKER=$($CONTAINER_CMD ps -a | grep -o [^[:blank:]]*buildbot-worker[^[:blank:]]*)

if [ -z $BUILDBOT_MASTER ] || [ -z $BUILDBOT_WORKER ]; then
  echo "ERROR: Did you run 'docker-compose up' or './container-compose up'?"
  exit 1
fi

# Create SSH keys.

rm -Rf   .ssh
mkdir -p .ssh
(cd      .ssh                       && \
  ssh-keygen -q -P "" -f "./id_rsa" && \
  cp id_rsa.pub authorized_keys)

echo "Keys successfully created in '.ssh' directory."

$CONTAINER_CMD cp .ssh/authorized_keys $BUILDBOT_MASTER:/root/.ssh/authorized_keys
$CONTAINER_CMD cp .ssh/id_rsa          $BUILDBOT_WORKER:/root/.ssh/id_rsa

$CONTAINER_CMD exec $BUILDBOT_MASTER chown root:root /root/.ssh/authorized_keys
$CONTAINER_CMD exec $BUILDBOT_WORKER chown root:root /root/.ssh/id_rsa

echo "Keys successfully deployed in '$BUILDBOT_MASTER' and '$BUILDBOT_WORKER'."
