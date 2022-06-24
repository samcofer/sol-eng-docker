# Kerberos Authentication to RStudio Workbench #

This docker image installs Kerberos tools on-top of the default RStudio
Workbench image. In addition, `sssd` is configured to obtain users from
an LDAP server and authenticate against a Kerberos server.

## Why no password forwarding? ##

Usually creating Kerberos tickets in Workbench are a prime example for
using PAM sessions with password forwading, c.f.
https://docs.rstudio.com/ide/server-pro/r_sessions/kerberos.html.
However, this is not used here! How and why is that possible?

A first hint that password forwarding might not be needed can be seen in
https://support.rstudio.com/hc/en-us/articles/360016587973-Integrating-RStudio-Workbench-RStudio-Server-Pro-with-Active-Directory-using-CentOS-RHEL
which does not touch PAM sessions but has a working krb5 ticket in the
end.

It turns out that this depends on the PAM module in use:

* Both versions of `pam_krb5` put the ticket into the ticket cache
  during [`pam_setcred`](https://man.cx/pam_krb5(5)), which is called by
  Workbench only during session creation in the `auth` stack. So this
  will only work together with password forwarding.
* For `pam_sss` I did not find documentation as to when the ticket is saved.
    * However, experimentally the above support article shows that this
      is possible. Interestingly, this is only mentioned for RHEL but
      not in the parallel article for Ubuntu.
    * By default `pam_sss` saves the ticket as `/tmp/krb5cc_UID_RANDOM`.
      This happens already with `pam_authenticate`. However, other tools
      like `klist` search for the ticket as `/tmp/krb5cc_UID`. The
      environment variable `KRB5CCNAME` that tells these tools where to
      look is only set during `pam_setcred` or `pam_open_session`.
    * This works on RHEL since they include a `/etc/krb5.conf` that
      defines a cache location (in the kernel's keyring) that is then
      used by both `pam_sss` and these other tools. This can also be
      implemented on Ubuntu, c.f. setting
      `libdefaults.default_ccache_name` in `/etc/krb5.conf` to use the
      kernel's keyring.

## Use the Kerberos ticket with Postgres ##

This image has RStudio Pro Drivers installed. The Postgres version of
these drivers does support Kerberos authentication. This can be used
together with the Postgres server available with

```bash
make kerb-postgres-build make-postgres-up
```

The relevant ODBC configuration is already present in `/etc/odbc.ini`:

```
[kerb-postgres]
Driver = PostgreSQL
Server = k-postgres
Database = postgres
UseKerberos = 1,
KerberosServiceName = postgres
Port     = 5432
```

One can use that on the commandline with `isql kerb-postgres $USER` or
in R with

```r
library(DBI)
> con <- dbConnect(odbc::odbc(),
                   "kerb-postgres",
                   UID=Sys.getenv("USER"))
```
