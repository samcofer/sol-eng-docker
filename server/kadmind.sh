#!/bin/sh
#
# Init the kadmind service at /usr/sbin
exec /usr/sbin/kadmind >> /var/log/service-kadmind.log 2>> /var/log/service-kadmind-error.log
