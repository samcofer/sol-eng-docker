#!/bin/bash

set -e
set -x

# Deactivate license when it exists
deactivate() {
    echo "Deactivating license ..."
    rstudio-server license-manager deactivate >/dev/null 2>&1
}
trap deactivate EXIT

# Activate License
if ! [ -z "$RSP_LICENSE" ]; then
    rstudio-server license-manager activate $RSP_LICENSE
elif test -f "/etc/rstudio/license.lic"; then
    rstudio-server license-manager activate-file /etc/rstudio/license.lic
fi

# lest this be inherited by child processes
unset RSP_LICENSE

# Create one user
if [ $(getent passwd $RSP_TESTUSER_UID) ] ; then
    echo "UID $RSP_TESTUSER_UID already exists, not creating $RSP_TESTUSER test user";
else
    if [ -z "$RSP_TESTUSER" ]; then
        echo "Empty 'RSP_TESTUSER' variables, not creating test user";
    else
        useradd -m -s /bin/bash -N -u $RSP_TESTUSER_UID $RSP_TESTUSER
        echo "$RSP_TESTUSER:$RSP_TESTUSER_PASSWD" | sudo chpasswd
    fi
fi

# Start sssd if it is configured
if [ -f "/etc/sssd/sssd.conf" ]; then
  # remove old PID file
  echo 'Removing old pid file'
  rm -rf /var/run/sssd.pid
  echo 'Starting sssd'
  sssd
fi

# Start Launcher
if [ "$RSP_LAUNCHER" == "true" ]; then
  /usr/lib/rstudio-server/bin/rstudio-launcher > /var/log/rstudio-launcher.log 2>&1 &
  wait-for-it.sh localhost:5559 -t $RSP_LAUNCHER_TIMEOUT
fi

# touch log files to initialize them
su rstudio-server -c 'touch /var/lib/rstudio-server/monitor/log/rstudio-server.log'
touch /var/log/rstudio-server.log

tail -n 100 -f /var/lib/rstudio-server/monitor/log/*.log /var/lib/rstudio-launcher/*.log /var/lib/rstudio-launcher/Local/*.log /var/log/rstudio-launcher.log /var/log/rstudio-server.log &

# the main container process
# cannot use "exec" or the "trap" will be lost
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0 > /var/log/rstudio-server.log 2>&1
