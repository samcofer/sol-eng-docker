# LDAP / Active Directory

This project contains information for using LDAP (or Active Directory... but
putting that in a docker container is hard).

## Getting started

Get started by executing:
```
make ldap-server-up
```

The `osixia/ldap` docker container comes provisioned with a domain of
`dc=example,dc=org`. To log into the browser, connect on the secure port (which
will yell at you because our cert is bogus). Then, login as:

```
user: cn=admin,dc=example,dc=org
pass: admin
```

Then you will be able to add / provision users, groups, etc.

### Provision Users

Provisioning users is presently a manual process that should ultimately be
improved by providing a `.ldif` file.  If you want a more complex tree
structure, you will need to "import" through the ldap-admin container. If using
Connect, you will also need to define several attributes (email, first / last
name, etc.).

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

As a result of this, we incorporated a postgres configuration into the Connect
compose file. `usermanager` should work. Just be judicious about the fact that
interacting with Connect in the browser while using `usermanager` _could_
potentially cause some strange consequences.


