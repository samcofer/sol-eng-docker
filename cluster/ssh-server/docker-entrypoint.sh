#!/bin/bash

set -e

/usr/local/bin/config_ssh_krb5.sh

exec "$@"

