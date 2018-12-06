# Auth Docker

This project houses docker infrastructure for quickly setting up, configuring, and testing authentication with RStudio Professional Software.

## Sub-Projects

- [Kerberos](./kerberos.md)
- [Oauth2 Proxy](./oauth2.md)
- [SAML](./saml.md)
- [General Proxy](./proxy.md)
- [LDAP](./ldap.md)
- [Kubernetes](./k8s.md)
- [SSL/TLS/HTTPS](./ssl.md)

# Getting Started

There are several users scripted into the systems at the outset.  These users
are in the [users](./cluster/users) file. They are `user pass` combinations.

To get started, you will need to install:
 - `make`
 - `docker`
 - `docker-compose`

Then look to specific sub-project pages (above) for detailed make commands to get things built and started.

# Examples

A handful of examples that might interest you
```
make ldap-up
make connect-up
make rsp-up
make kerb-up
make proxy-connect-up proxy-saml-up
```

# Organization

## [Docker Compose](./compose)

The [`./compose`](./compose) directory houses `docker-compose` `YAML`
configuration files. Feel free to use them directly or see how they are used in
the `Makefile`. Compose helps create a nice pattern of "saving" necessary
`docker` commands for easy re-use.

## [Cluster](./cluster)

The [`./cluster`](./cluster) directory is where individual nodes, configuration
files, Dockerfiles and other useful tidbits are stored.  Assets that are shared
or used in arbitrary builds can be stored in the root directory (builds
canonically start in [`./cluster`](./cluster)).  Assets that are used only for
an individual build are canonically stored in a subfolder relevant to that
build.

# Common Problems

- docker cache outdated: let's say it has been a while and your docker cache
  needs `apt-get update` to be run in order to install things.  `docker-compose 
  -f myfile.yml build --no-cache myservice` can get you unstuck! 

## Apache

- `ProxyPass` and `ProxyPassReverse` are not allowed within an `<If>` block... sad. Also, trying to use variables has also been painful

## Init Systems

There are a slew of them... [S6](todo), [systemctl](todo), [runit](todo),
systemd (avoid like the plague in Docker), and [dumb-init](todo), just to name
a few.

Init systems are interesting in docker-land.  Lots more needs to be written about this.

