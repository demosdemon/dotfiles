#!/usr/bin/env bash

function @test() {
  printf '[ %s ] == ' "$*"
  if test "$@"; then
    echo true
  else
    echo false
  fi
}

function @warn() {
  printf 'W: %s\n' "$@" >&2
}

function @error() {
  printf 'E: %s\n' "$@" >&2
}

function @trace() {
  local unset_x=true
  [[ $- == *x* ]] && unset_x=false

  set -x
  "$@"
  [ $unset_x == true ] && set +x
}

function @join() {
  local IFS=$1
  shift
  echo -n "$*"
}

function @split() {
  if [ $# -gt 1 ]; then
    local IFS=$1
    shift
  fi

  local printfd
  exec {printfd}< <(printf '%s\0' "$@")

  local -a values row
  while read -d $'\0' -r -a row -u $printfd; do
    values+=("${row[@]}")
    if [ ${#row[@]} -eq 0 ]; then
      break
    fi
  done
  exec {printfd}>&-

  printf '%q\n' "${values[@]}"
}

function @export() {
  local target value
  target=$1
  value=$2

  if [ "$value" ]; then
    eval "$(printf 'export %s=%q' "$target" "$value")"
  else
    eval "$(printf 'unset %s' "$target")"
  fi
}

function @prepend-path() {
  local target value target_value
  target=$1
  value=$2

  if [[ -z $target || -z $value ]]; then
    echo 'Usage: @prepend-path <path var> <path>' >&2
    return 2
  fi

  if [[ $target == *"PATH" && ! -e $value ]]; then
    return 0
  fi

  target_value=${!target}
  value=$(realpath "$value")
  if [[ ":${target_value}:" == *":$value:"* ]]; then
    local -a paths line
    local pipe

    pipe=$(@split ':' "${target_value}" | grep -v "^$value\$")
    # shellcheck disable=2162 # @split quotes
    while read -a line; do
      paths+=("${line[@]}")
    done <<< "$pipe"

    target_value=$(@join ':' "${paths[@]}")
  fi

  @export "$target" "${value}:${target_value}"
}
