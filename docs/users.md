# Users

Users are provisioned across these instances in a consistent fashion, using these primary aims:

- Use the same username / passwords across auth providers
- Groups exist where convenient
- In _most_ cases, `username` = `password` (for simplicity of remembering). Exception: `bobo:momo`

To view user / password combinations, visit the [users](../cluster/users) file

## Exceptions

Of course, there are exceptions.

- `base-rsp` comes with `rstudio:rstudio` only by default (no other users)
- `base-connect` comes with no users. Use `Sign Up` to create the first admin
- the `bobo` user has the password `momo`

## Venues

- [users](../cluster/users) - used to provision shell accounts, etc.
- [users.ldif](../cluster/users.ldif) - used to provision users within LDAP
- [users.php](../cluster/users.php) - used to provision users in the SAML IdP
