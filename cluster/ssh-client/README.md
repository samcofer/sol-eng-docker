# SSH Client with Kerberos Authentication #

This client connects to [ssh-server](../ssh-server) with Kerberos authentication.

In order to test the connection, you can (using user `bobo`):

```bash
su bobo
kinit
ssh k-ssh-server
```

You should be prompted for password during `kinit` and then not prompted for the `ssh` connection, which uses the issued Kerberos ticket.  Check that the ticket has been issued with `klist`.
