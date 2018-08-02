# Auth Docker

This project houses docker infrastructure for quickly setting up, configuring, and testing authentication with RStudio Professional Software.

## Sub-Projects

- [Kerberos](./Kerberos.md)
- [Oauth2 Proxy](./oauth2.md)

# Common Problems

- docker cache outdated: let's say it has been a while and your docker cache needs `apt-get update` to be run in order to install things.  `docker-compose -f myfile.yml build --no-cache myservice` can get you unstuck! 

## Init Systems

There are a slew of them... [S6](todo), [systemctl](todo), [runit](todo), systemd (avoid like the plague in Docker), and [dumb-init](todo), just to name a few.

Init systems are interesting in docker-land.  Lots more needs to be written about this.

