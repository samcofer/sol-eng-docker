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
[the root certificate](./cluster/ssl/auth-docker.pem) into your trusted
certificates, or by specifying it with something like `curl --cacert
auth-docker.pem https://myservice`

# Get Other Services / Containers to Trust the CA

- In Ubuntu (Bionic):
```
# BE CAREFUL WHAT openssl YOU ARE USING
which openssl
echo $PATH

# EDIT path if you are not using something like /usr/bin/openssl

# after mounting the .pem into the container
cp /ssl/auth-docker.pem /usr/local/share/ca-certificates/auth-docker.crt

dpkg-reconfigure ca-certificates
# or
update-ca-certificates
```

## Mac

### Chrome

Chrome uses the Mac OS Keychain. 

1. Open Mac Keychain app
2. Go to `File > Import Items...`
3. Select the private key file [./cluster/ssl/auth-docker.pem](./cluster/ssl/auth-docker.pem)
4. Search for `auth-docker` in the search bar
5. Double click on the root certificate in the list
6. Expand the `Trust` section
7. Change `When using this certificate:` select box to `Always Trust`

### FireFox

FireFox does _not_ use the MacOS Keychain. As a result, it requires configuring FireFox directly

1. Navigate to `about:preferences#privacy`
2. At the bottom, there is a button: `View Certificates`
3. Go to the `Authorities` tab
4. Click `Import...`
5. Select the private key file [./cluster/ssl/auth-docker.pem](./cluster/ssl/auth-docker.pem)
6. Check "Trust this CA to identify websites."
7. Click "OK"

## Ubuntu / Debian

This worked on at least one Debian server... see this [semi-helpful
link](https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html)
below for the pointers that led me there. `/usr/local/share/ca-certificates` is
also supposed to be a thing, along with `sudo update-ca-certificates`... but it
did not work in my testing.

```
cat auth-docker.pem >> /etc/ssl/certs/ca-certificates.crt
```

Test success with
```
curl https://some-service/
```

## Others

A [semi-helpful
link](https://manuals.gfi.com/en/kerio/connect/content/server-configuration/ssl-certificates/adding-trusted-root-certificates-to-the-server-1605.html)
or a google search can go a long ways!

# Learning SSL

- [Useful article on setting up a CA](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/)
- [Star Trek example](https://datacenteroverlords.com/2011/09/25/ssl-who-do-you-trust/)
- [cfssl api docs](https://github.com/cloudflare/cfssl/tree/master/doc/api)

## HTTPS Behind a Reverse Proxy

- Important to use the words "end-to-end", "upstream," or "re-encrypting" when searching
- [WELL written nginx example](https://reinout.vanrees.org/weblog/2017/05/02/https-behind-proxy.html)
- [get apache to avoid re-checking certs](http://httpd.apache.org/docs/2.4/mod/mod_ssl.html#sslproxycheckpeercn)
- [common problems with certs](https://www.apachelounge.com/viewtopic.php?t=6770)
- [SO post exlaining](https://security.stackexchange.com/questions/83082/end-to-end-encryption-with-a-reverse-proxy-and-an-application-server)
- [random example](https://ubuntuforums.org/showthread.php?t=2064909)

## Apache and SSL

- [ssl and apache overview](https://www.digicert.com/csr-ssl-installation/apache-openssl.htm)
- [rewrite http to https](https://wiki.apache.org/httpd/RewriteHTTPToHTTPS)
- [http to https redirect](https://www.namecheap.com/support/knowledgebase/article.aspx/9821/38/redirect-to-https-on-apache)

## nginx and SSL

- [nginx and ssl](https://medium.com/@mtourne/how-to-use-nginx-for-ssl-termination-for-any-domain-dc2e2c630058)
- [nginx redirect 80 to ssl](https://bjornjohansen.no/redirect-to-https-with-nginx)
- [related configuration of nginx and ssl](https://bjornjohansen.no/securing-nginx-ssl)

## FREE Certificates from LetsEncrypt

- [Getting Started](https://letsencrypt.org/getting-started/)
- [Using certbot](https://certbot.eff.org/lets-encrypt/ubuntutrusty-nginx)
- [user agreement](https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf)

## Some Examples and Helpers

- [Check internet SSL cert](http://web.archive.org/web/20100811030528/http://www.digicert.com:80/help)
- [simple-ca docker container](https://github.com/jcmoraisjr/simple-ca)
- [SSL on Docker and Traefik](https://jimfrenette.com/2018/03/ssl-certificate-authority-for-docker-and-traefik/)
- [Windows CA stuff](https://www2.microstrategy.com/producthelp/10.6/SystemAdmin/WebHelp/Lang_1033/Content/Admin/Adding_your_enterprise_CA_as_a_trusted_certificate.htm)
- [Docker and actual HTTPS...?](https://docs.docker.com/ee/ucp/interlock/usage/tls/#let-your-service-handle-tls)
- [how the encryption conversation works](https://www.digicert.com/ssl-cryptography.htm)
- [Symantec overview (TONS of docs)](https://www.websecurity.symantec.com/security-topics/how-does-ssl-handshake-work)
- [Resources for doing this in the public arena](https://www.keycdn.com/blog/ssl-trust)
- [Apparently we should call it TLS?](https://curl.haxx.se/docs/sslcerts.html)

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

