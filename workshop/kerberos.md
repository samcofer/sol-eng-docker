# Kerberos

## Getting Started

Similar to SAML, we will need some supporting services locally for Kerberos to
function. To simplify our lives, let’s start some of the build procedures (you
should have done this above)

```
make build
```

- Now let’s talk about what Kerberos is made up of:
    - Kerberos server (KDC) - issues kerberos tickets, has a “database” with identities / principals, does authorization, etc.
    - Kerberos “Service Principals” - provides kerberized services (i.e. SSH in our example, some databases, etc.)
    - Kerberos Principals - users, etc.
    - In most customer environments, Active Directory does all of this for them
- Some common issues:
    - Case sensitivity in domain names, etc.
    - Issues with PAM integration
    - Debugging is low-level linux operations
- Disclaimer: this infrastructure is pretty old (~2-2.5 years), so still uses krb5


## Exercises

Start the KDC (and a simple client) with:
```
make kerb-server-up
make kerb-ssh-up
make kerb-rsp-up
```

Now start a Kerberized SSH server:
```
make kerb-ssh-up
```

Now start a Kerberized RSP server:
```
make kerb-rsp-up
```

(If you see an issue here, try `make kerb-rsp-build` first)

If you get a bad response in your browser, check that the container is running with

```
docker ps | grep kerb-rsp
```

Or

```
./bin/pdocker ps kerb-rsp
```

If the container is not running, look at the logs with:

```
docker logs compose_kerb-rsp_1
```

If you see a message like:
```
...
{"result":23,"action":"activating product key","message":"The product key has already been activated with the maximum number of computers."}
== Exiting ==
…
```

Then you know you need to reset your license :) http://apps.rstudio.com/deactivate-license/

Once the license is fixed, run this again!
```
make kerb-rsp-up
```


NOW! Log into RStudio Server Pro using one of the users from ./cluster/users

Execute the following in your R session (to workaround an RSP bug)


(BEWARE - Google Docs means you will need to change your quotes… ugh)
```
Sys.setenv(“PATH” = “/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin”)
```

Then in your terminal try:

```
klist
ssh kerberos-ssh-server
hostname
````

Success!! You just used Kerberos to SSH! Notice that you did not have to use your password :)

Now destroy your credentials
```
klist
kdestroy
klist
ssh kerberos-ssh-server
kinit
ssh kerberos-ssh-server
```

## Follow-Up Exercises

- Destroy your credentials and restart the R session. What happens? (You will need to do the PATH fix again)
- Destroy your credentials and start a new R session. What happens? (You will need to do the PATH fix again)
- Deploy a Kerberized Connect instance:
```
make kerb-connect-build
make kerb-connect-up
```
- Deploy https://github.com/colearendt/shiny-shell and set the app to “Current User Execution”
- Use shiny-shell to ssh into kerberos-ssh-server and run a command:

```
ssh -o "StrictHostKeyChecking=no" kerberos-ssh-server hostname
ssh -o "StrictHostKeyChecking=no" kerberos-ssh-server id
ssh -o "StrictHostKeyChecking=no" kerberos-ssh-server klist
```

(Note - we have to turn host key checking off since we do not have an interactive shell to verify the new host: https://www.shellhacks.com/disable-ssh-host-key-checking/)

What other exercises would be useful?

