# Auth Docker

This project houses docker infrastructure for quickly setting up, configuring, and testing authentication with RStudio Professional Software.

## Sub-Projects

- [Kerberos](./Kerberos.md)

# Common Problems

- docker cache outdated: let's say it has been a while and your docker cache needs `apt-get update` to be run in order to install things.  `docker-compose -f myfile.yml build --no-cache myservice` can get you unstuck! 

