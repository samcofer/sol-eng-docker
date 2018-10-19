#!/bin/bash

if ( [[ -z `which curl` ]] || [[ -z `which jq` ]] ); then 
  echo 'ERROR: `curl` or `jq` not found. Both are required'; 
  exit 2;
fi

curl -d @cert_config.json http://cfssl:8888/api/v1/cfssl/newcert > new_cert.json

cat new_cert.json | jq -r '.result.certificate' > $(hostname).crt
cat new_cert.json | jq -r '.result.certificate_request' > $(hostname).csr
cat new_cert.json | jq -r '.result.private_key' > $(hostname).key
