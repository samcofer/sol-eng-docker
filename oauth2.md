# oauth2_proxy Configuration

There are a handful of examples that use the [oauth2_proxy](https://github.com/bitly/oauth2_proxy) docker images for authentication to RStudio Professional products.

In order to use these examples, you will first need to [register a Github oauth application](https://github.com/settings/developers).  This will provide the values that you need for `CLIENT_ID` and `CLIENT_SECRET`.  

## Helpful Tips

* Navigating to `/oauth2/sign_out` in the browser will log out of the oauth2_proxy. Note that this does not clear the GitHub memory, so signing back in is as easy as a click. Not sure how to completely clear the cache - there is probably some cookie that needs to be cleared.
* If you enable Multi-Factor Authentication (MFA) on your GitHub account (which you should do), this proxy seamlessly adds MFA to your RStudio products!

## Environment Variables

The OAUTH service is dependent on several environment variables.  To explore or use them yourself, it is best to copy the [example](./.env.example) to `.env` with something like:

```
cp .env.example .env
```

Then change the oauth2-related configuration variables accordingly.


# Lessons Learned

* nginx (with speed in mind) does not want to do DNS resolution at runtime.  If so you need to specify a resolver with resolver 8.8.8.8 or something like it. Note that this proves painful with docker images...
    - As a result, things like proxy_pass $my_dynamic_uri do not work as easily as expected (i.e. they need a resolver)
* Certain things cannot live within an if block. They need their own server or location (i.e. proxy_pass, auth_resolve, etc.)
* If you are redirecting (with a 307) for authentication, then that service ought to send you back to / when completed, so the nginx proxy can bypass authentication and proxy_pass to the right resources
* map statement is used to do if-like things... dynamic variable creation, etc.
* The x-rsc-request header is important to Connect functioning properly! An example on nginx:

```
proxy_set_header X-RSC-Request $scheme://$host:$server_port$request_uri;
```

* the oauth2-debug service is a container that echoes the HTTP requests (and headers) that reach it.  This makes it invaluable for debugging a HTTP proxy like `nginx`
* `proxy_pass` forwards traffic to an upstream service transparently
* `proxy_redirect` rewrites responses from the upstream service to ensure they are treated accurately when they reach the client
