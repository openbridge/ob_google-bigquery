#!/usr/bin/env bash

set -ex

HASH=$(git rev-parse HEAD) && echo $HASH
GCLOUD_SDK="cloud-sdk:$HASH"
GCLOUD_CONFIG="gcloud-config-$HASH"
PROJECT=${PROJECT:?missing, usage: PROJECT=GCLOUD-PROJECT test.sh}

function cleanup() {
  echo "Done!"
}
trap 'cleanup' 0
docker build -t ${GCLOUD_SDK} .
docker rm ${GCLOUD_CONFIG} || true
docker run --rm ${GCLOUD_SDK} gcloud info
docker run --rm ${GCLOUD_SDK} gcloud components list | grep 'Not Installed' && false
docker run -ti --name ${GCLOUD_CONFIG} ${GCLOUD_SDK} gcloud auth login
docker run --rm --volumes-from ${GCLOUD_CONFIG} ${GCLOUD_SDK} gcutil --project ${PROJECT} listinstances

exit 0
