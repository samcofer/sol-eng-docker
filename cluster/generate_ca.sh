#!/bin/bash
# thanks to https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/

private_key=auth-docker.key
private_key_nopass=auth-docker.key.nopass
pem_cert=auth-docker.pem

# generate private key
openssl genrsa -des3 -out ${private_key} 2048

# generate root certificate
# expires on my birthday in 2021... which also happens to be my 30th. fun :)
openssl req -x509 -new -nodes -key ${private_key} -sha256 -days 1000 -out ${pem_cert}

# un-password-protect the key 
# https://techjourney.net/how-to-decrypt-an-enrypted-ssl-rsa-private-key-pem-key/
openssl rsa -in ${private_key} -out ${private_key_nopass}
