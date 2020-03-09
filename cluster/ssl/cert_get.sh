#!/bin/bash

if [ -z ${1} ]; then
  URL="http://cfssl:8888"
else
  URL=${1}
fi
echo "${URL}"

if [ -z ${2} ]; then
  hostname=$(hostname)
else
  hostname=${2}
fi
echo "${hostname}"

if [ -z ${3} ]; then
  filename=${hostname}
else
  filename=${3}
fi
echo "${filename}"

if [[ -z `which curl` ]] || [[ -z `which jq` ]] ; then 
  echo 'ERROR: `curl` or `jq` not found. Both are required'; 
  exit 2;
fi

raw_json=`cat cert_config.json | jq --arg var "${hostname}" '.request.hosts[0] = $var | .request.CN = $var'`
echo "${raw_json}"
curl -d "${raw_json}" ${URL}/api/v1/cfssl/newcert > new_cert.json

echo "Writing ${filename}.crt into $(pwd)"
cat new_cert.json | jq -r '.result.certificate' > ${filename}.crt

echo "Writing ${filename}.csr into $(pwd)"
cat new_cert.json | jq -r '.result.certificate_request' > ${filename}.csr

echo "Writing ${filename}.key into $(pwd)"
cat new_cert.json | jq -r '.result.private_key' > ${filename}.key
