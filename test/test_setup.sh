#!/bin/bash
#set -x #echo on

# Webspace directory for the "master".
DATA_DIR=$(pwd)/data

# Leave empty in a distributed setup, necessary for local setup.
NETWORK_STR="--network=host"

function recreate_and_start_buildbot {
  echo "--------------------------------------------------------------------"
  echo "  Use '${CONTAINER_CMD}' to update the Buildbot '$1'."
  echo "--------------------------------------------------------------------"

  # Get the new image.
  ${CONTAINER_CMD} pull docker.io/siko1056/octave-buildbot:latest-$1

  # Stop and remove the old container.
  ${CONTAINER_CMD} stop octave-buildbot-$1
  ${CONTAINER_CMD} rm   octave-buildbot-$1

  # Create a new container from the new image.
  #
  #  Hint:
  #
  if [ "$1" = "master" ]; then
    mkdir -p ${DATA_DIR}
    ${CONTAINER_CMD} create \
      --mount type=volume,source=octave-buildbot-master,target=/buildbot/master \
      --mount type=bind,source=${DATA_DIR},target=/buildbot/data \
      --publish 8010:8010 \
      --publish 9989:9989 \
      ${NETWORK_STR} \
      --name octave-buildbot-master \
      siko1056/octave-buildbot:latest-master
  else
    ${CONTAINER_CMD} create \
      --env-file worker01.env \
      --name octave-buildbot-worker \
      --mount type=volume,source=octave-buildbot-worker,target=/buildbot \
      ${NETWORK_STR} \
      siko1056/octave-buildbot:latest-worker
  fi

  # Start the new container.
  ${CONTAINER_CMD} start octave-buildbot-$1

  # Display volume information.
  ${CONTAINER_CMD} volume inspect octave-buildbot-$1
}

function cleanup {
  # Stop and remove all containers.
  ${CONTAINER_CMD} stop octave-buildbot-worker
  ${CONTAINER_CMD} rm   octave-buildbot-worker
  ${CONTAINER_CMD} stop octave-buildbot-master
  ${CONTAINER_CMD} rm   octave-buildbot-master

  # Remove all volumes and the $DATA directory.
  ${CONTAINER_CMD} volume rm octave-buildbot-worker
  ${CONTAINER_CMD} volume rm octave-buildbot-master
  rm -Rf ${DATA_DIR}

  # Remove all images.
  #${CONTAINER_CMD} rmi siko1056/octave-buildbot:latest-worker
  #${CONTAINER_CMD} rmi siko1056/octave-buildbot:latest-master
}

# Detect supported container management tool.
if [ -x "$(command -v docker)" ]; then
  CONTAINER_CMD=docker
  IMG_PRUNE_FLAG="-f"
elif [ -x "$(command -v podman)" ]; then
  CONTAINER_CMD=podman
  IMG_PRUNE_FLAG=
else
  echo "ERROR: Cannot find 'docker' or 'podman'."
  exit 1
fi

# Determine task.
case $1 in
  "all")
    recreate_and_start_buildbot master
    recreate_and_start_buildbot worker
    ;;
  "master")
    recreate_and_start_buildbot master
    ;;
  "worker")
    recreate_and_start_buildbot worker
    ;;
  "cleanup")
    cleanup
    ;;
  *)
    echo "Usage: $0 {all|master|worker|cleanup}"
    exit 1
esac

# Clean up and show some useful statistics.
echo "--------------------------------------------------------------------"
echo "  Finished, some '${CONTAINER_CMD}' system information."
echo "--------------------------------------------------------------------"
${CONTAINER_CMD} image prune ${IMG_PRUNE_FLAG}
echo -e "\n\n  '${CONTAINER_CMD} system df'\n"
${CONTAINER_CMD} system df
echo -e "\n\n  '${CONTAINER_CMD} images'\n"
${CONTAINER_CMD} images
echo -e "\n\n  '${CONTAINER_CMD} ps -a'\n"
${CONTAINER_CMD} ps -a
