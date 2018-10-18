#!/bin/bash
# thanks to https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/

# generate private key
openssl genrsa -des3 -out myCA.key 2048

# generate root certificate
# expires on my birthday in 2021... which also happens to be my 30th. fun :)
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1000 -out myCA.pem
