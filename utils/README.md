## Example Usage


### `token.sh`

This script is used for emulating the `rsconnect` and IDE authentication mechanism
  - It was cribbed from the `rstudio/connect` repo long ago, and modified to be more modular

```
# generate a .pem key and initialize a token
./token.sh gen https://colorado.rstudio.com/rsc/


# use saved token to probe a URL
#  - on localhost
./token.sh probe
./token.sh probe http://localhost:3939 /__api__/me

#  - for a remote server with a path
HOST_BASE_PATH=/rsc ./token.sh probe https://colorado.rstudio.com/rsc/

# to make a request with existing signature
./token.sh probe https://colorado.rstudio.com/rsc/

# use a saved token to sign a request, but do not make it
HOST_BASE_PATH=/rsc ./token.sh sign https://colorado.rstudio.com/rsc/

#  - can also customize the date
DATE=$(date -u "+%a, %d %b %Y %H:%M:%S GMT") HOST_BASE_PATH=/rsc ./token.sh sign https://colorado.rstudio.com/rsc/
```
