#!/bin/bash

set -e
set -x

# Deactivate license when it exists
deactivate() {
    echo "== Exiting =="

    echo "Writing output to S3"
    aws s3 cp /output/ ${S3_BUCKET} --acl bucket-owner-full-control --recursive

    echo "== Done =="
}
trap deactivate EXIT

/usr/local/bin/shinycannon $@
