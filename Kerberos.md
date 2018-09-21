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
make network-up kerb-server-up kerb-ssh-up
```

Then connect to the running `k-ssh-server` and `k-ssh-client` containers with `docker exec -it <container name> bash`.  Consult the respective `README.md` files for more specific information.

On the other hand, if you want to test with RStudio:

```bash
make network-up kerb-server-up kerb-ssh-up kerb-rstudio-up
```

The license for RStudio Server Pro should be in an environment variable `RSP_LICENSE`.  This will get read by the build process and passed along / activated by the container. Then get things operational per the respective `README.md` files, log into RStudio Server Pro, and ssh to `k-ssh-server`. Blam!  No authentication question. Yep. Thank you, Kerberos.

There is even a kerberized Connect instance. To authenticate to the only available service (SSH), you will need a crafty Shiny app like [this one](todo) that gives you a shell. Again, only do-able thanks to Kerberos!

```bash
make network-up kerb-server-up kerb-ssh-up kerb-rsc-up
```

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

## Single-Sign-On (SSO)

- Need to set permissions on the service keytab to be readable... [random help](https://users.ece.cmu.edu/~allbery/lambdabot/logs/kerberos/2008-02-17.txt) 
 > failed to verify krb5 credentials: Permission denied, yet the auth.log shows tickets were granted
- Need to set default realm for services (i.e. `apache-kerb DOCKER-RSTUDIO.COM`) since we are not using FQDN
- Need to understand keytabs a bit better...
    - [generating a keytab](https://docs.tibco.com/pub/spotfire_server/7.6.1/doc/html/tsas_admin_help/GUID-27726F6E-569C-4704-8433-5CCC0232EC79.html)
    - [helpful post on curl negotiate](https://stackoverflow.com/questions/38509837/when-using-negotiate-with-curl-is-a-keytab-file-required)
    - [headless keytabs](https://community.hortonworks.com/questions/2435/why-is-kinit-with-a-headless-keytab-failing.html)
- Your service name _matters a lot!!!_. `Wrong principal name` issues may be related to the service trying to guess what its own name is and that guess conflicting with the client... [Thank you, SO](https://stackoverflow.com/questions/14687245/apache-sends-wrong-server-principal-name-to-kerberos)
- [Apache `mod_auth_kerb`](http://modauthkerb.sourceforge.net/configure.html) for the win
- Maybe a way in [nginx](https://stackoverflow.com/questions/37795107/how-to-kerberos-authentication-with-nginx) as well?
- Adding CGI scripts to apache is pretty cool
    - Make sure the script itself is executable
    - [Make sure `cgid_module` is enabled](http://httpd.apache.org/docs/current/howto/cgi.html)
    - In Kerberos context, you have to be sure that authentication _is_ in fact required (otherwise no Kerberos magic can happen)
    - [Some example bash scripts](http://www.yolinux.com/TUTORIALS/BashShellCgi.html)... [and a kerberos specific one](http://modauthkerb.sourceforge.net/credential-cache-example.script)
    - [A general overview](https://www.techrepublic.com/blog/diy-it-guy/diy-enable-cgi-on-your-apache-server/)
    - The weird thing here is that we either have to request the CGI script directly... or execute it every time..?
        - Have to figure out how to take the temporary credential cache and get a new one!
        - Maybe we can tell the browser to cache the request as long as the ticket is valid for? Or something?...
        - We _do_ have a TGT, so that is good!
        - [Some thoughts on this process](https://github.com/jcmturner/gokrb5/issues/7)
        - Basically, this would be much more trivial if I was RStudio... it's hard b/c when the Apache process dies, the cache goes bye-bye
        - Not to mention the fact that I am going to be on another host... so I may need to SSH onto the RStudio box and issue a ticket?
        - Not to mention the fact that the ticket issued on RStudio will not be tied to any PAM session or anything, so it will just expire
        - We are [getting to the heart](https://serverfault.com/questions/422778/how-to-automate-kinit-process-to-obtain-tgt-for-kerberos) of tickets, TGT, and keytabs here, people! 
    - More on [constrained delegation](https://www.coresecurity.com/blog/kerberos-delegation-spns-and-more)

### Useful `curl` commands

```bash
# simple kerberos authentication via the browser
curl -v -i -u : --negotiate http://apache-kerb:80/ 

# to allow delegation (kerberos usage on the server)
curl --delegation always -v -i -u : --negotiate http://apache-kerb:80/cgi-bin/krb.sh
```

### TODO
- TODO - a tinyproxy instance to make browsing easy without weird URL stuff...?
- TODO - a way to enable `KRB5_TRACE` for apache child processess... need to set ENV vars for child processes

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

