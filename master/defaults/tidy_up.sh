#!/bin/bash

# Helper script to tidy up a directory, e.g. `/buildbot/data/stable`, if a
# threshold given in MegaByte is exceeded.
#
# Usage:  ./tidy_up.sh 60000 /buildbot/data/stable

DATA_THRESHOLD=$1  # MegaByte
BUILD_SIZE="10000" # MegaByte
THRESHOLD=`expr $DATA_THRESHOLD - $BUILD_SIZE`

cd $2

echo "START tidy up"
echo "--> ${THRESHOLD} MB threshold. "

if [[ "$(du -sm | awk '{print $1;}')" > "${THRESHOLD}" ]]; then
  OLDEST_DIR=$(ls -tr | head -n 1)
  echo "--> $(du -sm | awk '{print $1;}') MB is too much, remove '${OLDEST_DIR}'!"
  rm -Rf ${OLDEST_DIR}
fi

echo "--> $(du -sm | awk '{print $1;}') MB now"
echo "FINISHED tidy up"
