#!/bin/bash

echo -e 'Hi! The r-session-debug container is starting\n'
ls -lha /usr/lib/rstudio-server/bin/

echo -e 'Starting tcpdump... \n'
#tcpdump -i any -s 65535 -w /tmp/tcpdump_output &

echo -e 'Starting...\n'
#python3 /stdin_echo.py /usr/lib/rstudio-server/bin/rserver-launcher-orig $@
exec "/usr/lib/rstudio-server/bin/rserver-launcher-orig" "$@"
