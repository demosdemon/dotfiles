#!/usr/bin/env bash

function @get-color() {
  local -A colors=(
    [black]=0
    [red]=1
    [green]=2
    [yellow]=3
    [blue]=4
    [magenta]=5
    [cyan]=6
    [white]=7
  )

  local modifier bold color
  local -a parts

  local bash_wrap=n

  if [ "$1" == '-bash' ]; then
    bash_wrap=y
    shift
  fi

  function @printf() {
    # shellcheck disable=SC2059,SC2155
    local v="$(printf "$@")"
    if [ "$bash_wrap" = y ]; then
      printf '\[%s\]' "$v"
    else
      printf %s "$v"
    fi
  }

  while [ "$#" -gt 0 ]; do
    case "$1" in
    reset)
      @printf '\e(B\e[m\n'
      shift
      continue
      ;;
    fg_reset)
      @printf '\e[m\n'
      shift
      continue
      ;;
    bg_reset)
      @printf '\e[49m\n'
      shift
      continue
      ;;
    bold)
      @printf '\e[1m\n'
      shift
      continue
      ;;
    esac

    IFS=_ read -ra parts <<< "$1"
    shift

    if [ "${#parts[@]}" -eq 1 ]; then
      modifier='fg'
      bold=''
      color="${parts[0]}"
    elif [ "${#parts[@]}" -eq 2 ]; then
      modifier="${parts[0]}"
      bold=''
      color="${parts[1]}"
    else
      modifier="${parts[0]}"
      bold="${parts[1]}"
      color="${parts[2]}"
    fi

    if [ "${modifier}" = bg ]; then modifier=40; else modifier=30; fi
    if [ -n "${bold}" ]; then bold='1;'; fi
    color="${colors[$color]}"

    @printf '\e[%s%dm\n' "${bold}" "$((modifier + color))"
  done
}
