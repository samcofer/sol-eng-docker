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
