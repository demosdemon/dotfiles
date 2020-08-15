#!/usr/bin/env bash

@init-secrets() {
  if ! [ "$_sops" ]; then
    if ! [ -e ~/.env.yaml ]; then
      return 0
    fi

    if ! command -v sops > /dev/null 2>&1; then
      @error "sops not installed, unable to decrypt secrets!"
      return 1
    fi

    export _sops=1
    eval "$(sops --output-type=json -d ~/.env.yaml | jq -r '. as $env | keys | .[] | "\(.)=\($env[.] | @sh); export \(.);"')"
  fi
}

@init-secrets
unset -f @init-secrets
