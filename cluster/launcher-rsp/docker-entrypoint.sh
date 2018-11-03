#!/bin/bash

#set -x

# set up kubernetes configuration
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

# check k8s health
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/healthz

# update launcher.conf file

echo "api-url=$K8S" > /etc/rstudio/launcher.kubernetes.conf
echo "auth-token=$TOKEN" >> /etc/rstudio/launcher.kubernetes.conf

mkdir -p /usr/local/share/ca-certificates/Kubernetes
cat $CACERT > /usr/local/share/ca-certificates/Kubernetes/cert-Kubernetes.crt
update-ca-certificates


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
