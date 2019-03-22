#!/usr/bin/with-contenv bash
## load /etc/environment vars first:
for line in $( cat /etc/environment ) ; do export $line ; done

#set -x

if [ "${PRODUCT}" == "LAUNCHER_K8S" ]; then

  # set up kubernetes configuration
  K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
  TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
  CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
  NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
  
  # check k8s health
  curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/healthz
  
  # update launcher.kubernetes.conf file
cat << EOF > /etc/rstudio/launcher.kubernetes.conf
api-url=$K8S
auth-token=$TOKEN
profile-config=/etc/rstudio/launcher.kubernetes.profiles.conf
EOF
  
# update launcher-staging.kubernetes.conf file
cat << EOF > /etc/rstudio/launcher-staging.kubernetes.conf
api-url=$K8S
auth-token=$TOKEN
profile-config=/etc/rstudio/launcher.kubernetes.profiles.conf
EOF
  
  mkdir -p /usr/local/share/ca-certificates/Kubernetes
  cat $CACERT > /usr/local/share/ca-certificates/Kubernetes/cert-Kubernetes.crt
  update-ca-certificates
  
  activate() {
  }
  
  deactivate() {
       echo "Stopping launcher..."
       rstudio-launcher stop
  }
  
  activate
  
  trap deactivate EXIT 

else 

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

fi

# start sssd
# we should really be more sophisticated than this...
sssd

echo "Running CMD"
exec "$@"
