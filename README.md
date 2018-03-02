# Kerberos on Docker

For the purposes of internal testing, this repo houses Kerberos running in a docker network orchestrated by `docker-compose.yml`.  Some simple users/passwords are included out of the box:

On Kerberos (which runs on k-server)

| user | password | role |
|------|----------|------|
|n/a   |pass      |master|
|ubuntu|ubuntu    |admin |
|bobo  |momo      |user  |

On simple-client:

|user | password  |
|-----|-----------|
|bobo |momo       |

This user can be tested with:
```bash
kinit bobo
<enter password>
klist
```

**NOTE:** All users in [the users file](cluster/users) will be automatically created throughout the system (in Kerberos and locally on each individual container).  Thank you, `awk`!!

# Get Started

We have attempted to make this project somewhat modular.  To test Kerberos with SSH, you can execute something like:

```bash
docker-compose -f kerberos-base.yml -f kerberos-ssh.yml up
```

Then connect to the running `k-ssh-server` and `k-ssh-client` containers with `docker exec -it <container name> bash`.  Consult the respective `README.md` files for more specific information.

On the other hand, if you want to test with RStudio:

```bash
docker-compose -f kerberos-base.yml -f kerberos-rstudio.yml up
```

You will need to take care of the license for RStudio Server Pro, and then you should be able to authenticate using Kerberos. The most fun to (presently) be had is to set up all of the above by executing:

```bash
docker-compose -f kerberos-base.yml -f kerberos-rstudio.yml -f kerberos-ssh.yml up
```

Then get things operational per the respective `README.md` files, log into RStudio Server Pro, and ssh to `k-ssh-server`.  Blam!  No authentication question.  Yep.  Thank you, Kerberos.

# Development Process
In short... we outline the painful development process that we went through below.

- Using CentOS was extraordinarily painful due to a weird credential issue... also, `systemd` does not seem to have good support inside Docker

- Using Ubuntu was painful due to a permissions issue... plus the OS is somewhat heavyweight

- Moved to baseimage, a lightweight Ubuntu image
  * Has a different init system (at `/etc/runit`)... still need to configure this better
  * Still had the permission issue... which I learned can be fixed by creating the directory `/etc/krb5.conf.d` (thanks for the unhelpful error message, Kerberos)
  * Lots of permissions issues still to work through before things will be functional!
  * The UID issue was resolved by using file-based credential store (removing the KEYRING credential store)

- Problems with baseimage...
  * runit has some [peculiar behavior...](http://smarden.org/runit/runsv.8.html)
    > If ./run exits ... runsv restarts ./run.
  * which does not pair well with [kerberos](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html)
    > Each server daemon will fork and run in the background.

- SUCCESS!!
  * Using what I knew about Kerberos from the baseimage, I got things working on Ubuntu using `supervisor`
  * Had to configure PORTs to be EXPOSED
  * Had to get the host-name set up right in kdc.conf

Long term: I like the idea of a lighter-weight image, but Ubuntu suffices for now!  (And it's really nice to have something working in a realistic fashion)

## Postgres Setup

- Setting an environment variable `KRB5_TRACE=/path/to/filename` turns out to be MASSIVELY helpful on the client side!
- I also turned up logging verbosity on Postgres server (which helped)  and on Kerberos server (which didn't help)
- It was important that the keytab was readable by the postgres service (dunce me did not make sure that was possible)
- Then the big trick is making sure that DNS lookup is happening properly, as well as realm lookup, and the auth user is matching in the database


## LDAP

It looks like OpenLDAP might be the ticket for setting up LDAP (and integrating with Kerberos):
 - [Docker Image](https://github.com/osixia/docker-openldap)
 - [Kerberos instructions](https://web.mit.edu/kerberos/krb5-latest/doc/admin/conf_ldap.html)

We really should think about how to make this "properly" modular... so you can choose LDAP + Kerberos, just LDAP, just Kerberos, etc.
 

# Research & Links

### PAM and Kerberos
 - [Deployment Guide](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/s1-kerberos-pam.html)

### Credential Cache
 - [Memory](https://serverfault.com/questions/855943/how-to-force-kerberos-to-use-in-memory-credential-cache)

### Troubleshooting...
 - [General Help](https://wiki.ncsa.illinois.edu/display/ITS/Kerberos+Troubleshooting+for+Unix#KerberosTroubleshootingforUnix-general)
 - [UID issue...](https://community.hortonworks.com/questions/11288/kerberos-cache-in-ipa-redhat-idm-keyring-solved.html)
   > we commented out "default_ccache_name = KEYRING:persistent:%{uid}" and it fixed.
 - [UID issue again...](https://bugzilla.redhat.com/show_bug.cgi?id=1017683)
 - [Fix permission issue](https://www.redhat.com/archives/freeipa-users/2017-January/msg00046.html)
 - [Piping output...](https://stackoverflow.com/questions/876239/how-can-i-redirect-and-append-both-stdout-and-stderr-to-a-file-with-bash)

### Useful Git Repos
 - [docker cluster](https://github.com/criteo/kerberos-docker)
 - [Install on RHEL 7](https://gist.github.com/ashrithr/4767927948eca70845db)

### General Docs
 - [kdc.conf](https://web.mit.edu/kerberos/krb5-1.12/doc/admin/conf_files/kdc_conf.html#dbdefaults)
 - [kdc install](https://web.mit.edu/kerberos/krb5-devel/doc/admin/install_kdc.html)
 - [Install overview](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/s1-kerberos-server.html)
 - [Realms and Principals](http://publib.boulder.ibm.com/tividd/td/framework/GC32-0803-00/en_US/HTML/plan20.htm)
 - [Creating keytab](https://kb.iu.edu/d/aumh)
 - [kadmind](https://web.mit.edu/kerberos/krb5-1.13/doc/admin/admin_commands/kadmind.html)
 - [Admin guide](https://web.mit.edu/kerberos/krb5-1.4/krb5-1.4/doc/krb5-admin.html)
 - [Admin local](https://web.mit.edu/kerberos/krb5-1.12/doc/admin/admin_commands/kadmin_local.html)
 - [Credential Cache](https://web.mit.edu/kerberos/krb5-1.12/doc/basic/ccache_def.html)

### SSH
 - [tutorial](https://uz.sns.it/~enrico/site/posts/kerberos/password-less-ssh-login-with-kerberos.html)
 - [another tutorial](https://docstore.mik.ua/orelly/networking_2ndEd/ssh/ch11_04.htm)
 - [client side example](https://blog.milessteele.com/posts/2014-03-17-kerberos-ssh.html)
 - [pam and kerberos... overkill?](https://www.linux.iastate.edu/content/using-pam-kerberos-authentication-and-group-access-control)
 - [useful!](https://sathisharthars.com/2013/05/07/configuring-ssh-with-kerberos-authentication/)

### Debugging
 - [issue with host name](https://www.redhat.com/archives/freeipa-users/2014-April/msg00182.html)

### Services
#### systemd
A lot of times, this requires you to bind mount `/sys/fs/cgroup` into the container, which I'm not sure I have on a Mac.
 - [systemd issues](https://forums.docker.com/t/any-simple-and-safe-way-to-start-services-on-centos7-systemd/5695)
 - [systemd discussion](https://github.com/moby/moby/issues/35317)
 - General warning: "Generally I'd really discourage using systemd"
 - [From the horse's mouth](https://hub.docker.com/_/centos/)
 - [cgroups on Mac](https://forums.docker.com/t/docker-cgroups-on-mac-os-x/14731)
 - [Converting scripts](https://fedoramagazine.org/systemd-converting-sysvinit-scripts/)

#### supervisor
 - [Unrelated bug?](https://unix.stackexchange.com/questions/281774/ubuntu-server-16-04-cannot-get-supervisor-to-start-automatically)

#### runit
 - [Overview docs](http://smarden.org/runit/index.html)

### Interesting Docker Stuff
#### Phusion/BaseImage
 - [Lightweight base image](https://github.com/phusion/baseimage-docker#whats_inside)
 - [New init process](http://smarden.org/runit/replaceinit.html)
 - [More docs](http://phusion.github.io/baseimage-docker/#solution)
 - [Tags on DockerHub](https://hub.docker.com/r/phusion/baseimage/tags/)

