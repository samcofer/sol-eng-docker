# LDAP / Active Directory

This project contains information for using LDAP (or Active Directory... but
putting that in a docker container is hard).

## Getting started

Get started by executing:
```
make ldap-up
```

This creates the necessary network (`make network-up`), the LDAP server (`make ldap-server-up`),
and starts RStudio Connect as well (`make ldap-connect-up`). The users and passwords pre-provisioned
are [listed here](./cluster/users).

The `osixia/ldap` docker container comes provisioned with a domain of
`dc=example,dc=org`. To log into the browser, connect to the [`ldapadmin`](./compose/ldap.yml)
container (whose port 80 is mapped to some ephemeral port on your host by default)

Then, login as:

```
user: cn=admin,dc=example,dc=org
pass: admin
```

This will give you access to alter / update the LDAP configuration from your
browser.  A handful of  users are provisioned in the system by default, and
have users/passwords listed [here](./cluster/users). For example, `user/pass` pairs
`bobo/momo`, `test/test` and `jen/jen`.

### Provision Users

Provisioning users can be done manually or by editing the appropriate [`.ldif`
file](./cluster/users.ldif).  If you want a more complex tree structure, you
will need to "import" through the ldap-admin container. If using Connect, you
will also need to define several attributes (email, first / last name, etc.).

An example ldif for adding a subtree under `dc=example,dc=org` is:
```
# Organization for Example Corporation
dn: dc=subtree,dc=example,dc=org
objectClass: dcObject
objectClass: organization
dc: subtree 
o: The Subtree!
description: The Subtree to Add!
```

## Connect

Connect with LDAP configuration can be started with:
```
make ldap-connect-up
```

Connect in a docker container provides an interesting experience when it comes
to LDAP:
 - `usermanager` is helpful in fixing issues in LDAP
 - `usermanager` with a `SQLite` database requires that the Connect service is
   stopped to execute
 - Stopping the Connect service in a docker container also removes the docker
   container

As a result of this, we incorporated a postgres configuration into the [Connect
compose file](./compose/ldap-connect.yml). `usermanager` should work. Just be
judicious about the fact that interacting with Connect in the browser while
using `usermanager` _could_ potentially cause some strange consequences.


## Resources

- [Article about provisioning LDAP store](https://www.openldap.org/doc/admin22/dbtools.html)
- [Information about OpenLDAP](http://www.openldap.org/doc/admin24/guide.html)
- [osixia docker openldap docs](https://github.com/osixia/docker-openldap)
- [osixia docker openldap admin docs](https://github.com/osixia/docker-phpLDAPadmin)
- [Docker health check! Super helpful](https://github.com/peter-evans/docker-compose-healthcheck)
