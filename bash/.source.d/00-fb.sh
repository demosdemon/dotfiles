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

updatemymac() {
  sudo bash -euxc '
    /opt/facebook/bin/funsize && 
    /opt/facebook/bin/fixmymac && 
    /usr/local/bin/santactl sync --clean --debug
  ' &&
    /usr/bin/kdestroy &&
    /usr/bin/kinit &&
    /usr/local/bin/cc-certs &&
    true
}

rebase() {
  local -r bk="${1:-remote/master}"
  local current_node parent_node dirty=0 public=0
  if hg identify --id | grep --quiet '+'; then
    dirty=1
    hg shelve
  fi

  current_node=$(hg log -r . -T '{node}')
  parent_node=$(hg log -r 'last(public() & ::.)' -T '{node}')
  if [ "$current_node" == "$parent_node" ]; then
    public=1
  fi

  hg pull
  hg rebase -r 'draft()' -d "$bk"
  if ((public)); then
    hg checkout "$bk"
  fi
  if ((dirty)); then
    hg unshelve
  fi
}

@import /etc/bashrc
@import /usr/facebook/ops/rc/master.bashrc
@import "${HOME}/.fbchef/environment"
@import "/data/users/$USER/bashrc.sh"
