# Proxied Authentication to RStudio #

This docker image installs RStudio Server Pro, as well as the necessary
configuration for proxied authentication. 

## Getting Started ##

This image will use the `RSP_LICENSE` environment variable provided to the
image at runtime or, failing that, provided in the parent environment.

This image depends on a properly configured proxy server sitting in front of
it.  The proxy server will need to take care of user authentication and then
set the appropriate header to communicate with RStudio Server Pro. See [this
section in the admin
guide](http://docs.rstudio.com/ide/server-pro/authenticating-users.html#proxied-authentication)
for more detail on proxied authentication.
