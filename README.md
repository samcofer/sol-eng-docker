In short... this is somewhat painful.

- Using CentOS was extraordinarily painful due to a weird credential issue... also, `systemd` does not seem to have good support inside Docker

- Using Ubuntu was painful due to a permissions issue... plus the OS is somewhat heavyweight

- Moved to baseimage, a lightweight Ubuntu image
  * Has a different init system (at `/etc/runit`)... still need to configure this better
  * Still had the permission issue... which I learned can be fixed by creating the directory `/etc/krb5.conf.d`
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

