#!/usr/bin/env bash
HOST=${2:-http://localhost:3939}

if [ -z "$1" ]; then
  echo "Must pass 'gen' 'probe' or 'req' as the first argument"
  echo "  Can also pass HOST as second argument"
  echo "  And PROBE_URL as third argument"
  exit 1
fi
if [[ $1 == "gen" ]]; then
  echo "--> Creating private.pem"
  # Create a RSA keypair
  openssl genrsa -out private.pem 2048
  # Export the public key (this is not a cert!)
  echo "--> Creating public.pem"
  openssl rsa -in private.pem -outform PEM -pubout -out public.pem
  # Export the key without passphrase to make like easier
  echo "--> Creating private_unencrypted.pem"
  openssl rsa -in private.pem -out private_unencrypted.pem -outform PEM

  # Generate a random "token"
  cat /dev/random | head -n 1 | sha1sum -b | cut -d' ' -f 1 > token.txt

  # Have the public key as a single line and make it var along the token
  export PUBLIC_KEY=$(cat public.pem | grep -v "\-\-\-\-\-" | awk 'NF {sub(/\r/, ""); printf "%s",$0;}')
  echo "--> PUBLIC_KEY=${PUBLIC_KEY}"
  export TOKEN=$(cat token.txt)
  echo "--> TOKEN=${TOKEN}"
  # Request a token auth, visit the returned URL to complete the process
  resp=`curl $HOST/__api__/tokens -X POST -H "Content-Type: application/json" -d "{\"token\":\"${TOKEN}\",\"public_key\":\"${PUBLIC_KEY}\"}"`
  echo "--> Full response: ${resp}"
  echo
  echo "Visit this url in your browser: "
  echo "$resp" | jq -r .token_claim_url
fi

if [[ $1 == "probe" ]]; then
  PROBE_URL="/__api__/me"
  if [[ $3 != "" ]]; then
    PROBE_URL=$3
  fi
  export TOKEN=$(cat token.txt)
  echo $(date -u "+%a, %d %b %Y %H:%M:%S GMT") > date.txt
  export DATE=$(cat date.txt)
  echo -n "GET
${PROBE_URL}
${DATE}
?" > canonical.txt
  cat canonical.txt | sha1sum -b | cut -d' ' -f 1 | xxd -r -p > hash.txt

  # NOTE: In theory the below should work but it doesn't.
  # It uses the same ASN format forced below but the hash cannot be recovered in go.
  #openssl dgst -sha1 -sign private_unencrypted.pem hash.txt > signature.txt
  #openssl dgst -sha1 -verify public.pem -signature signature.txt hash.txt
  # We prepend the ASN format to the hashed value to achieve what's expected in go

  # binary header as a workaround for an openssl shortcoming
  echo -n "3021300906052b0e03021a05000414" > asn.txt

  cat asn.txt | xxd -r -p > hashed.txt
  cat hash.txt >> hashed.txt
  # Sign the value. This way there's no ASN format present, just padding.
  openssl rsautl -sign -in hashed.txt -inkey private_unencrypted.pem -out signature.txt
  # Base64 the signature.
  echo $(cat signature.txt | base64) > signature64.txt
  export SIGNATURE=$(cat signature64.txt)
  # Did it work?
  curl "$HOST$PROBE_URL" -H "Date: $DATE" -H "X-Auth-Token: $TOKEN" -H "X-Auth-Signature: $SIGNATURE" -H "X-Content-Checksum: ?"
fi

if [[ $1 == "req" ]]; then
  PROBE_URL="/__api__/me"
  if [[ $3 != "" ]]; then
    PROBE_URL=$3
  fi
  export TOKEN=$(cat token.txt)
  export DATE=$(cat date.txt)
  export SIGNATURE=$(cat signature64.txt)
  # Did it work?
  curl "$HOST$PROBE_URL" -H "Date: $DATE" -H "X-Auth-Token: $TOKEN" -H "X-Auth-Signature: $SIGNATURE" -H "X-Content-Checksum: ?"
fi
