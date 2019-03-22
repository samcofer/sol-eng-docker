#!/bin/bash

# $1 must be defined and should be a filename
# if $2 is "encode", then the provider key will be base 64 encoded


## How it works

# - loop over lines in the file. for each line,
# - use `cut` to grab first value - this is the Connect GUID
# - use `cut` to grab the second value - this is the LDAP provider key
# - If "encode" is passed to the script, we base64 encode the LDAP provider key
# - We check that decoding the LDAP provider key gives us our original input
#   (this is probably not necessary, since it does not even catch the one issue
#   where `echo | base64` adds an errant newline character)
# - Execute the usermanager to update the user in the Connect database

if [ -z "$1" ] || [ ! -f "$1" ]; then
  echo "ERROR: you must provide a filename that exists (got: ${1})"
  exit 1
fi

echo "Starting loop"
echo "-----------------------"
while IFS= read -r line; do
  echo "Current line: $line"
  guid=$(echo -n "$line" | cut -d ' ' -f 1)
  key=$(echo -n "$line" | cut -d ' ' -f 2)
  echo "connect guid: **${guid}**"
  echo "ldap provider key: **${key}**"

  # potentially encode the provider_key
  if [ "$2" == "encode" ]; then
    echo "Base 64 encoding the provider key"
    # this -n is very important...
    # the error omission causes is also very hard to detect 
    final_key=$(echo -n "${key}" | base64)
    # this -d may need to be -D on some operating systems
    check_key=$(echo -n ${final_key} | base64 -d)
  else
    final_key=${key}
    check_key=${key}
  fi

  # check the encoding is reversible
  echo "Using provider_key: **${final_key}**"
  echo "Using check_key: **${check_key}**"
  if [ "${check_key}" != "${key}" ]; then
    echo "ERROR: Check key does not match original key!! This should not happen"
    exit 1
  fi

  # go ahead and update now...
  echo "Executing update"
  /opt/rstudio-connect/bin/usermanager alter --users --user-guid ${guid} --new-unique-id ${final_key}

  echo "-----------"
done < "$1"
