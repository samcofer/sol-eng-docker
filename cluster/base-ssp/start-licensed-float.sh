#!/bin/bash

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny:shiny /var/log/shiny-server

if [ -z "$LICENSE_SERVER" ]; then
    echo >&2 'error: The LICENSE_SERVER variable is not set.'
    "$@"
    exit 1
fi


activate() {
    echo "Activating license ..."
    /opt/shiny-server/bin/license-manager license-server ${LICENSE_SERVER} # output is informative.
    if [ $? -ne 0 ]
    then
        echo >&2 'error: LICENSE_SERVER could not be activated.'
        exit 1
    fi     
}

deactivate() {
    echo "Deactivating license ..."
    sudo /opt/shiny-server/bin/license-manager deactivate >/dev/null 2>&1
}

activate

# trap process exits and deactivate our license.
trap deactivate EXIT

echo "Starting shiny-server ..."
"$@"
STATUS="$?"
