#!/bin/bash

set -e
set -x

mkdir -p /output/

# Deactivate license when it exists
deactivate() {
    echo "== Trapped Exit Command =="

    echo "--> Killing java forcefully"
    kill -9 `pidof java`

    if [ -n "${S3_BUCKET}" ]; then
      echo "--> Writing output to S3"
      aws s3 sync /output/ "${S3_BUCKET}" --acl bucket-owner-full-control
    else
      echo "--> No S3 bucket defined. Not writing output"
    fi

    echo "== Done =="
    exit
}
trap deactivate EXIT

if [ -n "${S3_RECORDING_LOCATION}" ]; then
  echo "--> Getting recording.log from S3"
  aws s3 cp "${S3_RECORDING_LOCATION}" /recording.log
elif [ -n "${RECORDING_LOCATION}" ]; then
  echo "--> Getting recording.log from the internet"
  curl -o /recording.log "${RECORDING_LOCATION}"
fi

/usr/local/bin/shinycannon $@ --output-dir /output/$(date +'%s')-${HOSTNAME}
