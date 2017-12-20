In short... this is somewhat painful.

- Using CentOS was extraordinarily painful due to a weird credential issue... also, `systemd` does not seem to have good support inside Docker

- Using Ubuntu was painful due to a permissions issue... plus the OS is somewhat heavyweight

- Moved to baseimage, a lightweight Ubuntu image
  * Has a different init system (at `/etc/runit`)... still need to configure this better
  * Still had the permission issue... which I learned can be fixed by creating the directory `/etc/krb5.conf.d`
  * Lots of permissions issues still to work through before things will be functional!
