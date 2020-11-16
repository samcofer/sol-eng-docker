# Kerberos HA RSP

We have a Kerberos HA RSP setup that can be used pretty easily:

```
make kerb-rsp-build
make kerb-rsp-ha-up
```

You may need to run `make kerb-rsp-ha-up` again so that the nginx proxy comes
up. (There is a bit of a race condition here)

Then navigate to http://localhost:80/rstudio/ to log into the service using
`user:pass` `test:test` (or one of the other combos in
[`cluster/users`](../cluster/users)

## What is it

- [`compose/kerb-rsp-ha.yml`](../compose/kerb-rsp-ha.yml) defines the services
  and how they relate to one another
- two nodes kerb-rsp-ha-1 and kerb-rsp-ha-2
- a postgres database
- an nginx proxy (`kerb-rsp-ha-nginx`) that serves as a "front door"
  - note that this also load-balances the launcher (and terminates SSL for the launcher)

## Configuration

- most config is in [`cluster/kerb-rsp-ha/`](../cluster/kerb-rsp-ha/)
- The certs in the `certs/` directory were created using
  [`cluster/ssl/cert_get.sh`](../cluster/ssl/cert_get.sh) and the `make ssl-up`
  service

## Common Modifications 

- By default, this is setup to use the launcher. Disable by editing
  [`cluster/kerb-rsp-ha/rserver.conf`](../cluster/kerb-rsp-ha/rserver.conf)
