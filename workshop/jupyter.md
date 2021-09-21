# Jupyter

Jupyter is an option within RStudio Server Pro / RStudio Workbench.
This section will walk through building an example environment, debugging common
issues, and reproducing customer issues.

(Keep in mind that demo environments like https://colorado.rstudio.com/rstudio are also available for use!)

## Getting Started

Once [you have your environment set up](), here is a simple example environment that works out of the box.

```bash
make rsp-up
```

Now log into the UI at the port returned by this command, using the credentials `rstudio:rstudio`.

You should be able to start Jupyter Notebook or JupyterLab sessions and toy around with the IDE!

Try these ideas:

- Start a Python terminal
- Create a python notebook and enter some easy arithmetic (`2*4`, `4+3`, etc.)
- Start a bash terminal
- Use a bash terminal to install a package. `pip install pyyaml`
- Look at the output of `ps -ef` or `pstree -ap` (will need to `apt update && apt install pstree`) to see how processes
  relate to one another

## Python Path Issue

One common issue that happens with RStudio Server Pro is a mis-configured `jupyter.conf` file that points
to `jupyter-exe`. This _must be the same across all sessions_ (which causes problems particularly in Kubernetes).

So let's reproduce the problem!

Edit `cluster/jupyter.conf` and change 3.6.5 to 3.7.3 (this python version does not exist in our container)

_cluster/jupyter.conf_
```
jupyter-exe=/opt/python/3.7.3/bin/jupyter
notebooks-enabled=1
labs-enabled=1

default-session-cluster=Local
```

Then restart RStudio Server Pro:
```bash
make rsp-restart
```

Now log in and try to start a jupyter session again... weird, huh? At the time of
writing, you should get nothing in the UI... no error, no logs, nothing... So what do we do?

Let's go look at the logs:
```bash
docker exec -it compose_base-rsp_1 bash

cat /var/lib/rstudio-launcher/rstudio-launcher.log
```

Yeah... nothing really useful there. Let's look at some other logs...
```bash
# poke around in this directory... (user specific - rstudio is our username)
cat /var/lib/rstudio-launcher/Local/output/rstudio/

# for example:
cat /var/lib/rstudio-launcher/Local/output/rstudio/vOsaUhDSXIpZs9zJV9xlfg\=\=.stderr
```

Ahah! The problem that we expected! Not super intuitive to find, is it? ProdPad that puppy! :)

## What if the Launcher is not Started?

Part of the trick of debugging Jupyter sessions is debugging the launcher itself! (since jupyter
only works with Launcher). So what happens in the UI if the launcher is having issues...?

Revert our change to `jupyter.conf`:
```bash
git checkout -- cluster/jupyter.conf
```

Now edit `compose/base-rsp.yaml` and add an `environment` variable to disable launcher:
```yaml
    environment:
      RSP_LICENSES: ${RSP_LICENSE}
      RSP_LAUNCHER: "false"
```

Now restart RStudio Server Pro. Actually, after changing the
definition of `base-rsp.yml`, `rsp-up` gives what you want:
```bash
make rsp-up
```

Now log into the browser again, and what do you see? Launcher sessions are read-only! And _lots_
of these in the logs:

```bash
docker logs compose_base-rsp_1
# ...
08 Feb 2021 18:01:41 [rserver] ERROR system error 111 (Connection refused); OCCURRED AT void rstudio::core::http::TcpIpAsyncConnector::handleConnect(const rstudio_boost::system::error_code&, rstudio_boost::asio::ip::basic_resolver<rstudio_boost::asio::ip::tcp>::iterator) src/cpp/server/ServerSessionProxy.cpp:210; LOGGED FROM: rstudio::server::job_launcher::{anonymous}::ensureServerUserIsLauncherAdmin()::<lambda(rstudio::core::ExponentialBackoffPtr)>::<lambda(const rstudio::core::Error&)> src/cpp/server/ServerJobLauncher.cpp:860

# NOTE: in some cases, this error message is benign and just an intermittent connection issue...
# in our case, it is _definitely_ not benign
```

Also, you will notice that eventually (it doesn't take _that_ long, RSP will die / fall-over). You can `make rsp-up`
again to bring it back.

(Go back and remove the line you added from `compose/base-rsp.yml`)

## Start everything manually

What if you want to try some hackery and you need to start launcher / RSP interactively? We can do that too!

Edit `compose/base-rsp.yml` to change the command
```yaml
    command: ["sleep", "100000"]
```

(For reference, that is a day, and then the container will die. Adjust accordingly if you want RSP to live longer).
Then `make rsp-up`

Now log into the container:
```bash
docker exec -it compose_base-rsp_1 bash
```

And start things manually:
```bash
deactivate() {
    echo "Deactivating license ..."
    rstudio-server license-manager deactivate >/dev/null 2>&1
}
trap deactivate EXIT
/usr/lib/rstudio-server/bin/license-manager activate $RSP_LICENSE

# create a user
useradd -m -s /bin/bash -N -u $RSP_TESTUSER_UID $RSP_TESTUSER
echo "$RSP_TESTUSER:$RSP_TESTUSER_PASSWD" | sudo chpasswd

# background the launcher (could also run in a separate shell)
/usr/lib/rstudio-server/bin/rstudio-launcher > /var/log/rstudio-launcher.log 2>&1 &

# check launcher status
curl localhost:5559/status
# {"metrics":{"runTime":"00:00:24","totalRequests":1,"connectionCount":1},"status":"Green"}

# start RSP (takes your shell)
/usr/lib/rstudio-server/bin/rserver --server-daemonize 0 > /var/log/rstudio-server.log 2>&1
```

Now go log into the UI (the port was given when you first opened the container). You can also retrieve the port with:
```bash
docker ps | grep base-rsp
# or
./bin/pdocker ps base-rsp
```

And `exit` to leave your experiment / deactivate the license

To tear the container down:
```bash
make rsp-down
```

## Start jupyter outside of RSP

What does it look like to start jupyter manually? To see whether the issue is in our environment or in RSP?

First, you will need a port "exposed" on the docker container (so you can see it!). This works out well if we don't start RSP...

So let's start RSP as we did before (leave the `command: ["sleep", "100000"]` line configured)

```bash
make rsp-up
```

Now shell into the container:
```bash
docker exec -it compose_base-rsp_1 bash

# create our user again
useradd -m -s /bin/bash -N -u $RSP_TESTUSER_UID $RSP_TESTUSER
echo "$RSP_TESTUSER:$RSP_TESTUSER_PASSWD" | sudo chpasswd

# now assume the user
su rstudio

# and run a notebook
/opt/python/3.6.5/bin/jupyter notebook --port=8787 --ip=0.0.0.0
```

To use this URL, you will need to go to the URL shown (with token and such), but
using `http://localhost:dockerport` like `http://localhost:55011`.

To kill the notebook server, use `CTRL+C`.

Then try with jupyterlab
```bash
/opt/python/3.6.5/bin/jupyter lab --port=8787 --ip=0.0.0.0
```

Again, to kill, use `CTRL+C`.

This is how many open source users are familiar with executing Jupyter / JupyterLab locally! (Albeit not in docker)

Now clean up:
```bash
exit
make rsp-down
```

## Separate RSP and Launcher

This is not a common architecture, but it can give us a bit more understanding of how the different services work.

Start the launcher independently of RSP:
```bash
make launcher-up
```

Shell into the launcher container and create your user:
```bash
docker exec -it compose_launcher_1 bash

# create our user again
useradd -m -s /bin/bash -N -u $RSP_TESTUSER_UID $RSP_TESTUSER
echo "$RSP_TESTUSER:$RSP_TESTUSER_PASSWD" | sudo chpasswd

exit
```
> NOTE that we are making sure the UID is the same...
 
Configure RSP to use the launcher service by modifying `cluster/base-rserver.conf`:

_cluster/base-rserver.conf_
```ini
launcher-address=launcher
```

Add this volume to `compose/base-rsp.yml`
```yaml
    # under volumes...
    # volumes: 
      - ../shared/local-launcher/home/:/home
```

And start a fresh RSP:
```bash
make rsp-down rsp-up
```

Now log into the browser and start a session!

Execute this code to see where your session is running...
```
system("hostname")
```

## Final Note

`launcher-sessions-callback-address` has been misconfigured the whole time... in order to properly configure it, we will
need to make the port that RSP listens on consistent (rather than choosing a random / ephemeral port at runtime)
