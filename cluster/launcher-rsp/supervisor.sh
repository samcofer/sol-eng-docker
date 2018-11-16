#!/bin/bash

ls -lha /tmp
ls -lha /tmp/diagnostics
mkdir -p /tmp/diagnostics
chmod -R 777 /tmp/diagnostics

ehco 'look at home'
ls -lha /home
ls -lha /home/bobo

echo 'ping nfs01'
ping nfs01 -c 3

mkdir -p /tmp/blah
echo 'trying to mount'
mount nfs01:/ /tmp/blah

echo 'cat diagnostics file'
for file in `ls /tmp | grep '.log'`; do cat /tmp/$file; done;

"$@"
