# SAML

The following outlines the implementation of SAML used in the auth-docker repo, as well as a handful of the pain points experienced.

# Getting Started

To get started, ensure you have run `make test-env-up`. Then run:

```
make saml-idp-up saml-connect-up
```

This will stand up RStudio Connect with SAML authentication.

## Notes

- Our current SAML IdP only supports a single "Service Provider" (SP) at a
  time.  This means that if you want to use RSP, for instance, you will need to
  modify this file and change the SP URL:
  [../compose/saml-idp.yml](../compose/saml-idp.yml)
- You need to add an entry in `/etc/hosts` to facilitate the IdP routing (it is
  important that both the container and your host can route to `saml-idp` with
  the same URL, which requires an entry in `/etc/hosts`)
```
127.0.0.1	saml-idp
```

## Credentials

Users are provisioned via [`../cluster/users.php`](../cluster/users.php).
However, for simple login, an easy reference of `user pass` combinations is
available at [`../cluster/users`](../cluster/users)

## Example workflow

- Login: Go to http://localhost . This will prompt you for authentication before permitting you to access backend resources
- Logout: Go to http://localhost/secret/logout?ReturnTo=http://localhost
	- NOTE: this is currently broken... so you will get a `BadRequest` response... however, LogOut will be successful... so just go to http://localhost and you will be prompted for authentication
- If you want to login to the SAML IdP, the `user:pass` is `admin:secret`

# Development Background

## Tools Used

- Apache [mod_auth_mellon](https://github.com/Uninett/mod_auth_mellon) module as SAML Service Provider (SP)
- Docker [test-saml-idp](https://hub.docker.com/r/kristophjunge/test-saml-idp/) as SAML Identity Provider (IdP)

## Lessons Learned

- The XML MetaData is _extremely important_ to a SAML implementation. 
- Many of the communication errors that happen are issues with the metadata definition
- It can be helpful to install a SAML filter for devtools. I
  used [this one](https://chrome.google.com/webstore/detail/saml-devtools-extension/jndllhgbinhiiddokbeoeepbppdnhhio)
- If setting up `ProxyPass` to an endpoint (which should happen after authentication), you need to "bypass" the proxy
  for the `mod_auth_mellon` endpoint. This is done with `ProxyPass /secret/ !` (i.e. do not proxy `/secret/`).
- The `mod_auth_mellon` implementation is _very_ dependent on the URL/port you are addressing... this is painful in
  docker-land + EC2... at present, configuration uses `localhost`. TODO: make this easier to use
- The test IdP we are using needs to have the SP defined at startup (using environment variables)


## Resources

- [SAML overview picture](https://github.com/Uninett/mod_auth_mellon/blob/master/doc/user_guide/mellon_user_guide.adoc#45-saml-web-sso-flow)
- On the Logout Request failure we are still facing: [related-issue](https://github.com/UNINETT/mod_auth_mellon/issues/61)
- [Very useful mod_auth_mellon guide](https://github.com/Uninett/mod_auth_mellon/blob/master/doc/user_guide/mellon_user_guide.adoc)
- [printing variables with PHP](https://stackoverflow.com/questions/37839967/how-do-i-get-the-username-once-logged-in-with-mod-auth-mellon)
- [more generic mod_auth_mellon install instructions](https://github.com/UNINETT/mod_auth_mellon/wiki/GenericSetup)
- [mod_auth_mellon in another IdP](https://www.keycloak.org/docs/3.3/securing_apps/topics/saml/mod-auth-mellon.html)
- [info about SAML metadata](https://documentation.commvault.com/commvault/v11/article?p=3709.htm)
- [wiki about SAML metadata](https://en.wikipedia.org/wiki/SAML_Metadata)
- [deep dive on SAML stuff](https://groups.google.com/forum/#!topic/simplesamlphp/LwiLTF9APx0)

- [SAML and SSL](https://docs.oracle.com/cd/E19182-01/820-0595/ggswc/index.html)
