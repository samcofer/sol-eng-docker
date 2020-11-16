# Solutions Engineering Docker

This project houses docker infrastructure for quickly setting up, configuring,
and testing customer environments with RStudio Professional Software.

## Sub-Projects

### Auth Workshop

There is an "Auth Workshop" with a more curated walkthrough of these resources.
Visit `#auth-workshop` or checkout the docs!

- [Auth Workshop](./workshop)

### Tested

- [Kerberos](./docs/kerberos.md)
- [SAML](./docs/saml.md)
- [LDAP](./docs/ldap.md)

### Untested

- [General Proxy](./docs/proxy.md)
- [Oauth2 Proxy](./docs/oauth2.md)
- [Kubernetes](./docs/k8s.md)
- [SSL/TLS/HTTPS](./docs/ssl.md)
- [Floating Licenses](./cluster/float/README.md)
- [Metrics / Prometheus / Grafana](./docs/metrics.md)
- [Kerberos HA RSP](./docs/kerberos-ha-rsp.md)

# Getting Started

First you need a license! Mosey on over to `#support` and ask for a dev license
key for the product you are interested in testing against.  You need to be sure
that the license key will run in a hypervisor (i.e. Docker).

Then export the variable as `RSC_LICENSE`, `RSP_LICENSE`, or `RSPM_LICENSE`, as
the case may be.

```
export RSC_LICENSE=my-rsc-key
export RSP_LICENSE=my-rsp-key
export RSPM_LICENSE=my-rspm-key
```

There are several users scripted into the systems at the outset.  These users
are in the [users](./cluster/users) file. They are `user pass` combinations.

To get started, you will need to install:
 - `git`
 - `make`
 - `docker`
 - `docker-compose`
 - `bash`
 - `python3` (on your PATH)

First step is to clone the repository. I recommend doing this [over
SSH](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).
You will need to:
- provide GitHub with an SSH key. If you do not have one (check with `ls
  ~/.ssh`), you can generate it with
```
ssh-keygen
```
- then upload `id_rsa.pub` (THE PUBLIC PART! Not the other one!) to GitHub under:
    - Dropdown in top right corner
    - "Settings"
    - "SSH and GPG Keys"
    - "New SSH Key"
- then clone with (the URL will be different if you are using HTTPS):
```
git clone git@github.com:rstudio/sol-eng-docker.git
```

Move into the directory:
```
cd sol-eng-docker
```

Once done, you can run the following (from a bash shell) to check your environment:
```
# ensure you are IN the repository!
pwd
make check
```

Then you can run this to pre-pull important images:
```
make pull
```

Your first step will be:
```
make test-env-up
```

Then look to specific sub-project pages (above) for detailed make commands to get things built and started.

NOTE: If you are using Windows, we recommend starting a [git
bash](https://gitforwindows.org/) terminal so you can use the numerous `bash`
conventions that we employ

# Examples

A handful of examples that might interest you
```
make test-env-up
make ldap-server-up
make connect-up
make rsp-up
make kerb-server-up
make proxy-connect-up proxy-saml-up
make ldap-connect-up
```

# Organization

## [Docs](./docs)

The [`./docs](./docs) directory houses documentation around the various
options, projects, and examples that exist in this repository.

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

## [Kubernetes](./k8s)

The [`./k8s`](./k8s) directory is where individual kubernetes asset configuration files
live. These will often build on or from [`./cluster`](./cluster) resources.

**NOTE: These are not well maintained**

# Common Problems

- HELP, I am on Windows!!
    - You do need a `bash` shell, so we recommend using `git bash` or Windows Sub-system Linux (WSL)
    - Beware checking out windows-style line endings in `git`. This will break `bash` in a myriad of ways
- The `docker network` does not exist yet
    - Run `make test-env-up` to resolve this issue
```
ERROR: Network sol-eng-docker_default declared as external, but could not be found. Please create the network manually using `docker network create sol-eng-docker_default` and try again.
```
- Volume mounts are not working...?
    - We recommend _NOT_ running docker / cloning this repo as `root`
    - The reason for this is a bit tricky, but basically you need to set `privileged: true` on containers that use mounts or docker will not be able to read the files you are mounting into the container
- docker cache outdated: let's say it has been a while and your docker cache
  needs `apt-get update` to be run in order to install things.  `docker-compose
-f myfile.yml build --no-cache myservice` can get you unstuck if you are
building images!

# Conventions

- RStudio Server is proxied at `/rstudio` or listens on 8787
- Shiny Server is proxied at `/shiny` or listens on 3838
- RStudio Connect is proxied at `/rsconnect` or listens on 3939
- If at all possible, try to make images extensible and mount configuration
files into the image at runtime (so you just have to restart the container, not
rebuild it)
- We use `dumb-init` whenever possible as a lightweight service manager
- Proxied auth headers use `X-Secret-User-Header`
- `make some-key-up` targets compose file `compose/some-key.yml` and executes `up -d`
- `make some-key-down` targets compose file `compose/some-key.yml` and executes `down`

# Testing

There are several `make` targets that are tested in CI to prevent backwards
incompatibilities. To see which of these are tested, you should have a look at
the [`Jenkinsfile`](./Jenkinsfile).

# Reference

## Init Systems

There are a slew of them... [S6](todo), [systemctl](todo), [runit](todo),
systemd (avoid like the plague in Docker), [tini](todo) and [dumb-init](todo), just to name
a few.

Init systems are interesting in docker-land.  Lots more needs to be written about this.
