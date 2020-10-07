#!/bin/bash
#set -x #echo on

# - Information for volume target ending with ":z" or ":Z"
#   https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label
#
#   For podman this must be ":z,exec" or ":Z,exec"

function recreate_and_start_buildbot {
  echo "--------------------------------------------------------------------"
  echo "  Use '${CONTAINER_CMD}' to update the Buildbot '$1'."
  echo "--------------------------------------------------------------------"

  # Create a new container from the new image.
  if [ "$1" = "master" ]; then
    ${CONTAINER_CMD} create \
      --publish 8010:8010 \
      --publish 9989:9989 \
      --volume octave-buildbot-master:/buildbot/master:Z${EXEC_FLAG} \
      --volume octave-buildbot-master-data:/buildbot/data:z${EXEC_FLAG} \
      --name   octave-buildbot-master \
      gnuoctave/buildbot:latest-master

    ${CONTAINER_CMD} create \
      --env NGINX_HOST=localhost \
      --env NGINX_PORT=80 \
      --publish 8000:80 \
      --volume octave-buildbot-master-data:/usr/share/nginx/html/buildbot/data:z${EXEC_FLAG} \
      --volume $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
      --name   octave-buildbot-master-web \
      nginx
    ${CONTAINER_CMD} start octave-buildbot-master-web
  else
    # "--network=host" only necessary for local setup.
    ${CONTAINER_CMD} create \
      --network=host \
      --env BUILDMASTER=localhost \
      --env BUILDMASTER_PORT=9989 \
      --env WORKERNAME=worker01 \
      --env WORKERPASS=secret_password \
      --env CCACHE_NODISABLE=1 \
      --volume octave-buildbot-worker:/buildbot:Z${EXEC_FLAG} \
      --name   octave-buildbot-worker \
      gnuoctave/buildbot:latest-worker
  fi

  # Start the new container.
  ${CONTAINER_CMD} start octave-buildbot-$1
}

function cleanup {
  # Stop and remove all containers.
  ${CONTAINER_CMD} stop octave-buildbot-worker
  ${CONTAINER_CMD} rm   octave-buildbot-worker
  ${CONTAINER_CMD} stop octave-buildbot-master
  ${CONTAINER_CMD} rm   octave-buildbot-master
  ${CONTAINER_CMD} stop octave-buildbot-master-web
  ${CONTAINER_CMD} rm   octave-buildbot-master-web

  # Remove all volumes and the $DATA directory.
  ${CONTAINER_CMD} volume rm octave-buildbot-worker
  ${CONTAINER_CMD} volume rm octave-buildbot-master
  ${CONTAINER_CMD} volume rm octave-buildbot-master-data

  # Remove all images.
  #${CONTAINER_CMD} rmi gnuoctave/buildbot:latest-worker
  #${CONTAINER_CMD} rmi gnuoctave/buildbot:latest-master
}

function update {
  # Get the newest images.
  ${CONTAINER_CMD} pull docker.io/gnuoctave/buildbot:latest-master
  ${CONTAINER_CMD} pull docker.io/gnuoctave/buildbot:latest-worker
  ${CONTAINER_CMD} pull nginx
}

# Detect supported container management tool.
if [ -x "$(command -v docker)" ]; then
  CONTAINER_CMD=docker
  IMG_PRUNE_FLAG="-f"
  EXEC_FLAG=
elif [ -x "$(command -v podman)" ]; then
  CONTAINER_CMD=podman
  IMG_PRUNE_FLAG=
  EXEC_FLAG=",exec"
else
  echo "ERROR: Cannot find 'docker' or 'podman'."
  exit 1
fi

# Determine task.
case $1 in
  "up")
    recreate_and_start_buildbot master
    recreate_and_start_buildbot worker
    ;;
  "master")
    recreate_and_start_buildbot master
    ;;
  "worker")
    recreate_and_start_buildbot worker
    ;;
  "down")
    cleanup
    ;;
  "update")
    update
    ;;
  *)
    echo "Usage: $0 {up|down|master|worker|update}"
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
