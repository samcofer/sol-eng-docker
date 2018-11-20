#!/bin/bash

if [ -z `which jq` ]; then
  echo 'ERROR: `jq` was not found on your `PATH`, and it is required'
  exit 1
fi

ip_addr=`kubectl --namespace=rstudio get service nfs01 -o json | jq -r '.spec.clusterIP'`
res=$?
if [ $res -gt 0 ]; then
  echo "ERROR getting IP address: ${ip_addr}"
  exit 1
fi

# ... inject this IP into the necessary files...?
# with an _UGLY_ regex... I really need to learn sed better

echo "Found IP address: ${ip_addr}"

echo "Replacing in cluster/launcher-rsp/launcher-mounts"
cat cluster/launcher-rsp/launcher-mounts | sed "s/Host: [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/Host: ${ip_addr}/" > ...tmpfile
mv ...tmpfile cluster/launcher-rsp/launcher-mounts

echo "Replacing in cluster/launcher-rsp-ldap/launcher-mounts"
cat cluster/launcher-rsp-ldap/launcher-mounts | sed "s/Host: [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/Host: ${ip_addr}/" > ...tmpfile
mv ...tmpfile cluster/launcher-rsp-ldap/launcher-mounts

echo "Replacing in k8s/pv.yml"
cat k8s/pv.yml | sed "s/server: [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*/server: ${ip_addr}/" > ...tmpfile
mv ...tmpfile k8s/pv.yml
