#!/bin/bash

# This script assumes that the Buildbot Master directory is
# `$BUILDBOT_MASTER_DIR`.
# It is recommended to mount this directory as volume (for example
# "octave-buildbot-master") by Docker, e.g.
#
#   docker create \
#     --mount type=volume,ssource=octave-buildbot-master,target=/buildbot/master \
#     ...
#
# This way the state of the Buildbot Master is preserved.

BUILDBOT_MASTER_DIR=/buildbot/master

# Create `$BUILDBOT_MASTER_DIR` directory if it does not exist.
if [[ ! -d "$BUILDBOT_MASTER_DIR" ]]
then
  mkdir $BUILDBOT_MASTER_DIR
fi

# Copy default configuration if none exists.
if [[ ! -f "$BUILDBOT_MASTER_DIR/master.cfg" ]]
then
  cp /buildbot/master.cfg $BUILDBOT_MASTER_DIR
fi

# Copy helper script if not exists.
if [[ ! -f "$BUILDBOT_MASTER_DIR/tidy_up.sh" ]]
then
  cp /buildbot/tidy_up.sh $BUILDBOT_MASTER_DIR
fi

# Create a fresh Buildbot Master if no previous found.
if [[ ! -f "$BUILDBOT_MASTER_DIR/buildbot.tac" ]]
then
  buildbot create-master -r $BUILDBOT_MASTER_DIR
fi

# Eventually cleanup Buildbot Master leftovers from previous runs.
rm -f $BUILDBOT_MASTER_DIR/twistd.pid

# Wait for db to start by trying to upgrade the Buildbot Master.
until buildbot upgrade-master $BUILDBOT_MASTER_DIR
do
  echo "Can't upgrade master yet. Waiting for database ready?"
  sleep 1
done

cd $BUILDBOT_MASTER_DIR

# exec is used here so that twistd use the pid 1 of the container, and so that
# signals are properly forwarded.
exec twistd -ny $BUILDBOT_MASTER_DIR/buildbot.tac
