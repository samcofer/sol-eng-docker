# Postgres

The PostgreSQL docs for enabling Kerberos are generally very good.  You can find them [here](https://www.postgresql.org/docs/current/static/auth-methods.html) with extra information linked within (and user name mappings [here](https://www.postgresql.org/docs/current/static/auth-username-maps.html).

The way this image is set up:

- Starts from the `postgres` base image... 12 in this case
- Installs Kerberos software
- Provisions with a Kerberos configuration script which also adjusts
  configuration files, so that we do not have to persist database state with a volume
- Provisions the the database with users based on the [users](../users) file
- Executes the configuration script as part of the entrypoint

Some pain points we hit:

- Use `export KRB5_TRACE=/path/to/log/file` to increase Kerberos client logging verbosity
- We increased the Postgres server logging verbosity.  Turn this off if you plan to run the server for any length of time
- Make sure the postgres user can read the files you create... :/
- Make sure that the users being mapped and the users in the database match up appropriately! (Thanks postgres debug logs!)
