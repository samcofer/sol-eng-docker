#!/bin/bash

set -e

# start syslog
rsyslogd

# there has to be a better way
# have to wait for the KDC to come up
sleep 10

/usr/local/bin/config_ssh_krb5.sh

exec "$@"

