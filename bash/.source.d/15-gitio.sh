#!/usr/bin/env bash

# Create a git.io short URL
function gitio() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    echo 'Usage: gitio slug url'
    return 1
  fi
  curl -i http://git.io/ -F "url=${2}" -F "code=${1}"
}
