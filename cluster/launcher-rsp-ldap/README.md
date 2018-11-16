# Base RStudio Server Pro #

This docker image installs RStudio Server Pro, and not a whole lot else.
 
## Getting Started ##

Set the `RSP_LICENSE` environment variable in your local session, or set it in your `docker-compose up` command with `RSP_LICENSE=something docker-compose -f base-rsp.yml up`.  Note that the latter should only be used on systems that are secure - `ps` and friends will have access to the license in this case.

## Thoughts ##

We have diverged from `rocker` by not making the image _as small as possible_.  I.e. some cleanup to do in the future:

- we did not remove all of the `apt` stuff...
- we use `gdebi` instead of `dpkg`

