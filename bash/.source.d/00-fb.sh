#!/usr/bin/env bash

alias stripcolors='sed "s/\x1B\[\([0-9]\{1,2\}\(;[0-9]\{1,2\}\)\?\)\?[mGK]//g"'

# paste with title
pwt() {
  printf -v cmd '%q ' "$@"
  eval "$cmd 2>&1" | pastry --title "$cmd"
}

# paste with title to stdout
pwto() {
  local tmpf
  export PYTHONUNBUFFERED=x
  tmpf=$(mktemp -q)
  printf -v cmd '%q ' "$@"
  trap 'pastry --title "$cmd" < "$tmpf"; rm -rf "$tmpf"' RETURN
  eval "$cmd 2>&1" | tee "$tmpf"
}

@import /etc/bashrc
@import /usr/facebook/ops/rc/master.bashrc
@import "${HOME}/.fbchef/environment"
@import "/data/users/$USER/bashrc.sh"
