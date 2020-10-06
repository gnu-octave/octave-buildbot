#!/bin/bash

# Start up script for the Buildbot Master.

DEFAULT_DIR=/buildbot/defaults
BUILDBOT_DIR=/buildbot/master

# Create directory structure if necessary.
if [[ ! -d "$BUILDBOT_DIR" ]]
then
  mkdir -p $BUILDBOT_DIR
fi

# Copy default Buildbot configuration if not exists.
if [[ ! -f "$BUILDBOT_DIR/master.cfg" ]]
then
  cp $DEFAULT_DIR/master.cfg $BUILDBOT_DIR
fi

# Copy helper script if not exists.
if [[ ! -f "$BUILDBOT_DIR/tidy_up.sh" ]]
then
  cp $DEFAULT_DIR/tidy_up.sh $BUILDBOT_DIR
fi

# Copy helper app if not exists.
if [[ ! -d "$BUILDBOT_DIR/app" ]]
then
  cp -R $DEFAULT_DIR/app $BUILDBOT_DIR
fi

# Create a fresh Buildbot Master if no previous found.
if [[ ! -f "$BUILDBOT_DIR/buildbot.tac" ]]
then
  buildbot create-master -r $BUILDBOT_DIR
  rm -f $BUILDBOT_DIR/master.cfg.sample
fi

# Eventually cleanup leftovers from previous runs.
rm -f $BUILDBOT_DIR/twistd.pid

# Wait for db to start by trying to upgrade the Buildbot Master.
until buildbot upgrade-master $BUILDBOT_DIR
do
  echo "Can't upgrade master yet. Waiting for database ready?"
  sleep 1
done

cd $BUILDBOT_DIR

# exec is used here so that twistd use the pid 1 of the container, and so that
# signals are properly forwarded.
exec twistd -ny $BUILDBOT_DIR/buildbot.tac
