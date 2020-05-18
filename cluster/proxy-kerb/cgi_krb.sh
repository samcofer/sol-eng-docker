#!/bin/sh
######################################################################
#
# Example CGI script that uses Kerberos credentials cached by
# mod_auth_kerb compiled with caching option.
#
# Submitted by: Von Welch <vwelch@ncsa.uiuc.edu>
#
# mod_auth_kerb - Daniel Henninger <daniel@ncsu.edu>
#
######################################################################

# Output HTML header
echo Content-type: text/html
echo Status: 302
echo Location: /
echo

# $REMOTE_USER should be set by httpd
if [ -z "$REMOTE_USER" ]; then
    echo '$REMOTE_USER not set.'
    exit 1
fi

echo "REMOTE_USER is $REMOTE_USER"

if [ -z "$KRB5CCNAME" ]; then
    echo 'Kerberos credential cache name $KRB5CCNAME does not exist.'
    exit 1
fi

# Do Kerberos stuff
klist >> /tmp/output.txt

# another way to redirect
# echo '<head><meta http-equiv="refresh" content="0; url=/"/></head>'

# sleep to let us inspect the server if we want to
sleep 30

exit 0
