#!/bin/bash

# alias to make it easier to reference the rstudio namespace
alias kr="kubectl --namespace=rstudio"

# replace the docker image names in k8s files
function set_k8s_gce() {
  export K8S_IMAGE_PREFIX=us.gcr.io/rstudio-soleng
}

function set_k8s_local() {
  export K8S_IMAGE_PREFIX=rstudio
}

function set_image_prefix() {
  sed -i .bk -E "s/(image:).*\/(.*)$/\1 ${K8S_IMAGE_PREFIX//\//\\/}\/\2/" $1
}

function set_all_image_prefixes() {
  set_image_prefix ./k8s/launcher-ldap.yml
  set_image_prefix ./k8s/launcher.yml
  set_image_prefix ./k8s/ldap.yml
  set_image_prefix ./k8s/nfs.yml
  set_image_prefix ./k8s/rsp-ldap.yml
}

function get_k8s_images() {
  grep -rnw ./k8s -e 'image:' --exclude=helpers.sh --exclude=*.bk
}

# TODO: Helpers for `port-forward` and `get -o yaml` that use a regex?
