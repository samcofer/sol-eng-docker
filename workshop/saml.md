# SAML

## Getting Started
- SAML is an authentication protocol that is very strict about URLs in your browser. As a result, the type of “port changing” “localhost” stuff we just did will unfortunately not work for our SAML setup. Some differences from our last setup:
    - Connect will be accessed at http://localhost:3939 
    - We will need a “SAML IdP” (Identity Provider). We have a toy example in
      docker that we will use at http://saml-idp:8080/ 
    - Users will be pre-provisioned, so you will need to choose an account that
      already exists. These users are defined in ./cluster/users.php
- To get started, run this in your terminal:

```
sudo vim /etc/hosts
```
- Then add a line like the following to the end of the file, save, and quit:
```
127.0.0.1       saml-idp
```

- Now you’re ready to start the SAML IdP!

```
make saml-idp-up
```

- Navigating to this URL won’t give you anything interesting. However, to
  ensure it is up, you can navigate to http://saml-idp:8080/simplesaml/
- Now start a SAML Connect instance!!

```
make saml-connect-up
```

- Now navigate to http://localhost:3939 in your browser! You should see
  Connect! Click “Login”, which should redirect you to the SAML IdP. Choose one
of the user/pass combinations in the cluster/users.php file, and login!

- _Success!! You just created a SAML IdP!!_

## What black magic is this?
No magic, I promise. Let’s see what we did here. This repository uses the following pattern almost universally:

make -> docker-compose -> docker -> do the things we want

The directories for this are:
- compose/ - for docker-compose files. Does docker container networking and parameter definition
- cluster/ - for configuration files, resources, etc.
- support/ - a budding directory for “broken” configuration files and nice ways to stand up broken products in docker for debugging

Let’s look at the difference between our first two exercises thus far:
- Open compose/base-connect.yml and compose/saml-connect.yml in separate windows. What differences do you see?
- One simple way to do this:
```
vimdiff compose/base-connect.yml compose/saml-connect.yml
```

- Open cluster/base-connect.gcfg and cluster/saml-connect.gcfg in separate windows. What differences do you see here?
- For completeness, look at compose/saml-idp.yml . This is the IdP-in-a-docker-container that we are using to provide the SAML IdP service

## Follow-Up Exercises:
- Open up an incognito window and navigate to http://localhost:3939 . Log in as a different user than you chose last time. Notice that this user picked up the Connect default role!

- Change the Server.Address field in cluster/saml-connect.gcfg to http://test:3939. Then restart the container, log out and log back into Connect. What happens? Why?

- Change Server.Address back to the working value (http://localhost:3939), restart Connect. Now remove “/acs” from the configuration in ./compose/saml-idp.yml. Restart the saml-idp with `make saml-idp-up`. Log out and log back into Connect. What happens? Why?

- Fix your configuration, and fix the IdP by executing `make saml-idp-up`

- Advanced: this will be a bit tricky. Can you switch our original Connect server over to SAML? Some general steps that will be needed:
    - We will have to take down our current saml-connect implementation so that port 3939 is open
```
make saml-connect-down
```
    - Change the base-connect.gcfg to look like the saml-connect.gcfg. You can either modify this file directly, copy over it, or change the mount in compose/base-connect.yml . 
    - Change compose/base-connect.yml so that Connect listens on port 3939 (i.e. swap 3939 for 3939:3939)
    - Then run `make connect-up` again
    - Debug debug debug! Remember to use the logs to help you!
```
docker logs compose_connect_1
```

## Clean up

Want to clean up? (or start fresh?)
- Purge local file changes with `git checkout -- ./path/to/file` (or save them with `git stash`)
- Destroy services with `make saml-connect-down saml-idp-down`
