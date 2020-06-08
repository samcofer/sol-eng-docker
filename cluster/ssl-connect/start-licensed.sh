#!/bin/bash
if [ -z "$RSC_LICENSE" ]; then
    echo >&2 'error: The RSC_LICENSE variable is not set.'
    "$@"
    exit 1
fi


activate() {
    #echo "Activating license ..."
    #sudo /opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE # output is informative.
    #if [ $? -ne 0 ]
    #then
    #    echo >&2 'error: RSC_LICENSE could not be activated.'
    #    exit 1
    #fi     

    # Activate License
    if ! [ -z "$RSC_LICENSE" ]; then
        /opt/rstudio-connect/bin/license-manager activate $RSC_LICENSE
    elif ! [ -z "$RSC_LICENSE_SERVER" ]; then
        /opt/rstudio-connect/bin/license-manager license-server $RSC_LICENSE_SERVER
    elif test -f "/etc/rstudio-connect/license.lic"; then
        /opt/rstudio-connect/bin/license-manager activate-file /etc/rstudio-connect/license.lic
    fi
}

deactivate() {
    echo "Deactivating license ..."
    sudo /opt/rstudio-connect/bin/license-manager deactivate >/dev/null 2>&1
}

activate

# trap process exits and deactivate our license.
trap deactivate EXIT

echo 'Executing SSL script'
# set up SSL
/cert_get.sh http://cfssl:8888 ssl-connect

# lest this be inherited by child processes
unset RSC_LICENSE
unset RSC_LICENSE_SERVER

echo "Starting connect ..."
/opt/rstudio-connect/bin/connect --config /etc/rstudio-connect/rstudio-connect.gcfg
