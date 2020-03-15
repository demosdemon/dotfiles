#!/usr/bin/env bash

function @set-options() {
  # http://wiki.bash-hackers.org/internals/shell_options
  local -a enable_opts=(
    autocd
    cdspell
    checkhash
    checkjobs
    checkwinsize
    cmdhist
    complete_fullquote
    expand_aliases
    extglob
    extquote
    globstar
    histappend
    histreedit
    histverify
    lithist
    no_empty_cmd_completion
    nocaseglob
  )

  local -a disable_opts=(
    cdable_vars
    direxpand
  )

  for opt in "${enable_opts[@]}"; do
    shopt -s "$opt" 2> /dev/null
  done

  for opt in "${disable_opts[@]}"; do
    shopt -u "$opt" 2> /dev/null
  done
}

@set-options
unset -f @set-options

# these do not need to be exported
HISTCONTROL=ignorespace:erasedups
# HISTFILE="$HOME/.bash_history"
HISTFILESIZE=$((2 ** 17))
HISTIGNORE="l:ls:cd:cd -:pwd:exit:date"
HISTSIZE=$((2 ** 16))
HISTTIMEFORMAT='%F %r '
