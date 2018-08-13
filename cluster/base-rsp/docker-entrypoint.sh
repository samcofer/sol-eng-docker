#!/bin/bash

#set -x

if [ -z "${RSP_LICENSE}" ]; then
    echo >&2 'error: The RSP_LICENSE variable is not set.'
    "$@"
    exit 1
fi

activate() {
    echo "Activating license ..."
    /usr/lib/rstudio-server/bin/license-manager activate $RSP_LICENSE 2>&1
    if [ $? -ne 0 ]
    then
        echo >&2 'error: RSP_LICENSE could not be activated.'
        exit 1
    fi     
}

deactivate() {
     echo "Deactivating license ..."
     /usr/lib/rstudio-server/bin/license-manager deactivate >/dev/null 2>&1
}

activate

trap deactivate EXIT 

echo "Starting RStudio Server Pro"
exec "$@"
