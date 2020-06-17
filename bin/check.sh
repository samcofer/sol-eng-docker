#!/bin/bash

echo -e "\n---> Checking environment...\n"

if [[ -z `which bash` ]] ; then 
  echo 'ERROR: `bash` not found. Please install `bash` or `git-bash` (windows)'; 
  exit 2;
fi

if [[ -z `which python3` ]] ; then 
  echo 'ERROR: `python3` not found. Please install docker before proceeding'; 
  exit 2;
fi

if [[ -z `which docker` ]] ; then 
  echo 'ERROR: `docker` not found. Please install docker before proceeding'; 
  exit 2;
fi

if [[ -z `which docker-compose` ]] ; then 
  echo 'ERROR: `docker-compose` not found. Please install docker-compose before proceeding'; 
  exit 2;
fi

echo "---> Environment check complete. Good to go!"
