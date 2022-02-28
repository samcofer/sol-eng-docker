#!/bin/bash

echo -e "\n---> Checking environment...\n"

if [[ -z `which bash` ]] ; then 
  echo 'ERROR: `bash` not found. Please install `bash` or `git-bash` (windows)'; 
  exit 2;
else
  echo '    - found `bash`'
fi

if [[ -z `which python3` ]] ; then 
  echo 'ERROR: `python3` not found. Please install docker before proceeding'; 
  exit 2;
else
  echo '    - found `python3`'
fi

chk_vers=`python3 -c 'import sys; print((3,7) <= (sys.version_info.major, sys.version_info.minor))'`
if [[ "chk_vers" != "True" ]]; then
  echo "ERROR: Need python version 3.7 or greater. Please update python"
  echo "    if you need to use an older version, you can disable the ./bin/pdocker script by deleting its contents"
  echo "    for instance:"
  echo "      echo '' > bin/pdocker"
  exit 2;
else
  echo '    - found python version greater than 3.7'
fi

if [[ -z `which docker` ]] ; then 
  echo 'ERROR: `docker` not found. Please install docker before proceeding'; 
  exit 2;
else
  echo '    - found `docker`'
fi

if [[ -z `which docker-compose` ]] ; then 
  echo 'ERROR: `docker-compose` not found. Please install docker-compose before proceeding'; 
  exit 2;
else
  echo '    - found `docker-compose`'
fi

docker run --rm alpine:latest echo '    - running a `docker` example...'
docker_exit=$?
if [[ ! "$docker_exit" -eq 0 ]] ; then
  echo 'ERROR: a simple docker test did not work. Please ensure that `docker` is running and you have access to use it!';
  exit 2;
else
  echo '    - `docker` is functional!'
fi

# TODO: do a similar test but with compose! (`podman` on RHEL 8 causes trouble with `docker-compose`)

echo "---> Environment check complete. Good to go!"
