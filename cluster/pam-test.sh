#!/bin/bash

touch /tmp/login-file
echo `env` >> /tmp/login-file.log
echo `id` >> /tmp/login-file.log
echo `getent passwd` >> /tmp/login-file.log

exit 0
