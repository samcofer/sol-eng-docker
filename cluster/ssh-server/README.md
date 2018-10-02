# SSH Server with Kerberos Authentication #

This SSH server is configured to use Kerberos authentication.  However, in order to be successful, you must first execute `configure_ssh_krb5.sh` as root.  It should be on your path, but just to be safe, execute:

```bash
bash /usr/local/bin/configure_ssh_krb5.sh
```

This script creates a `host/k-ssh-server` principal and then generates a related keytab for use by the `sshd` service when authenticating users.  Then go to [ssh-client](../ssh-client) for connecting to the server.

## Helpful Notes ##

List current tickets with `klist` and look at the keytab with `klist -kt`

## To Do ##

- Add rsyslogd to the mix with `apt-get install -y rsyslog`.  It is executed with `rsyslogd`, but can probably be called from [`supervisord.conf`](./supervisord.conf) somehow, as well.
- Add `ssh-keyscan -H ssh-server >> /etc/ssh/ssh_known_hosts` to entrypoint scripts for clients... presuming that the SSH service is up and healthy... which probably should have its own health-check, to be honest...
    - https://unix.stackexchange.com/questions/33271/how-to-avoid-ssh-asking-permission
    - https://www.techrepublic.com/article/how-to-easily-add-an-ssh-fingerprint-to-your-knownhosts-file-in-linux/
    - https://unix.stackexchange.com/questions/3651/making-ssh-hosts-global-to-all-the-users-on-the-computer
