# Auth Docker

This project houses docker infrastructure for quickly setting up, configuring, and testing authentication with RStudio Professional Software.

## Sub-Projects

- [Kerberos](./Kerberos.md)


# Getting Started

There are several users scripted into the systems at the outset.  These users are in the [users](./cluster/users) file. They are `user pass` combinations.

To get started, you will need to install:
 - `make`
 - `docker`
 - `docker-compose`

Then look to specific sub-project pages (above) for detailed make commands to get things built and started.

# Common Problems

- docker cache outdated: let's say it has been a while and your docker cache needs `apt-get update` to be run in order to install things.  `docker-compose -f myfile.yml build --no-cache myservice` can get you unstuck! 

## Init Systems

There are a slew of them... [S6](todo), [systemctl](todo), [runit](todo), systemd (avoid like the plague in Docker), and [dumb-init](todo), just to name a few.

Init systems are interesting in docker-land.  Lots more needs to be written about this.

