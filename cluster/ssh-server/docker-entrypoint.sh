#!/bin/bash

set -e

# there has to be a better way
sleep 10

/usr/local/bin/config_ssh_krb5.sh

exec "$@"

