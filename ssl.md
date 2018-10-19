# SSL

# CA setup

Current Password for auth-docker.key: `pass`

Use [this shell script](./cluster/ssl/cert_authority_get.sh) to refresh /
generate new CA tokens. Our current token expires in 7/14/2021

# Adding SSL to a service

- Ensure that the SSL key-generating service is up with `make ssl-up`. This
  starts an [api](https://github.com/cloudflare/cfssl/tree/master/doc/api) that
can be used for generating certificates
- Use the commands in the
  [./cluster/ssl/cert_get.sh](./cluster/ssl/cert_get.sh) script along with the
example config in [this json file](./cluster/ssl/cert_config.json) to get a
certificate for your service
- Configure your service to use the appropriate `.crt` and `.key` files

# Development / Stop the "insecure" warnings

To do this, you need to trust the Certificate Authority! Do so by importing
[the root certificate](./cluster/ssl/auth-docker.pem) into your browser trusted
certificates, or by specifying it with something like `curl --cacert
auth-docker.pem https://myservice`

**IMPORTANT NOTE**: This still does not work like we want from our browsers,
because docker is an intermediary messing with things, and we have not yet
configured intermediate certificates. PRs welcome :)

# Learning SSL

- [Useful article on setting up a CA](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)
- [Star Trek example](https://datacenteroverlords.com/2011/09/25/ssl-who-do-you-trust/)
- [cfssl api docs](https://github.com/cloudflare/cfssl/tree/master/doc/api)

## Some Examples and Helpers

- [Check internet SSL cert](http://web.archive.org/web/20100811030528/http://www.digicert.com:80/help)
- [simple-ca docker container](https://github.com/jcmoraisjr/simple-ca)
- [SSL on Docker and Traefik](https://jimfrenette.com/2018/03/ssl-certificate-authority-for-docker-and-traefik/)
- [Windows CA stuff](https://www2.microstrategy.com/producthelp/10.6/SystemAdmin/WebHelp/Lang_1033/Content/Admin/Adding_your_enterprise_CA_as_a_trusted_certificate.htm)
- [Docker and actual HTTPS...?](https://docs.docker.com/ee/ucp/interlock/usage/tls/#let-your-service-handle-tls)
- [how the encryption conversation works](https://www.digicert.com/ssl-cryptography.htm)
- [Symantec overview (TONS of docs)](https://www.websecurity.symantec.com/security-topics/how-does-ssl-handshake-work)
- [Resources for doing this in the public arena](https://www.keycdn.com/blog/ssl-trust)

## My Guess at an Overview / Brain Dump

1. Client Hello... 
2. Server Hello...
3. Server sends server public key / cert
4. Client authenticates server cert using CA root cert (public)...
5. Client creates "master" secret (private / public pair) (think of this as a session secret)
6. Client encrypts public master secret using server cert and sends to server
7. Server decrypts public master secret using server private key

Communication continues... Client has private master, server has public master

- Intermediates make this a bit more tricky, because there is a chain of other encryptions / decryptions going on...

