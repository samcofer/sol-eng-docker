#!/bin/sh
#
# Init the krb5-kdc service at /usr/sbin
exec /usr/sbin/krb5kdc >> /var/log/service-krb5kdc.log 2>> /var/log/service-krb5kdc-error.log
