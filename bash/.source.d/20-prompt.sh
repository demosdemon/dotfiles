#!/usr/bin/env bash

COLOR_PROMPT=0
if [ "$FORCE_COLOR_PROMPT" ]; then
  COLOR_PROMPT=1
else
  case "$TERM" in
  *color) COLOR_PROMPT=1 ;;
  xterm*) COLOR_PROMPT=1 ;;
  screen*) COLOR_PROMPT=1 ;;
  esac
fi

unset -f update_terminal_cwd # get rid of Apple's in /etc/bashrc
function update_terminal_cwd() {
  if [ "$TERM_PROGRAM" == "Apple_Terminal" ] && [ -z "$INSIDE_EMACS" ]; then
    local PWD_URL
    PWD_URL=$(python3 -c 'import sys, pathlib; sys.stdout.write("\n".join(map(lambda x: pathlib.Path(x).absolute().as_uri(), sys.argv[1:])))' "$PWD")
    printf '\e]7;%s\a' "$PWD_URL" ## For apple terminal
  else
    printf '\e]0;\w\a' ## For everything else
  fi
}

function @set-prompt() {
  local last_exit_code=$?
  local ps1_start ps1_end

  # flush cmd usage history
  history -a

  # shellcheck disable=2046
  function @color() { ((COLOR_PROMPT)) && printf %s $(@get-color -bash "$@"); }
  function @open-brace() {
    @color bold black
    printf %s [
    @color reset
  }
  function @close-brace() {
    @color bold black
    printf %s ']'
    @color reset
  }
  # shellcheck disable=2015
  function @user-color() { if ((EUID)); then @color magenta; else @color red; fi; }
  function @status-code() {
    (($1)) || return 0
    @open-brace
    @color red
    printf %03d "$1"
    @close-brace
  }
  function @history() {
    @open-brace
    @color yellow
    printf %s '!\!'
    @close-brace
  }
  function @user-host() {
    @open-brace
    @user-color
    printf %s \\u
    @color reset bold black
    printf %s @
    @color reset bold blue
    printf %s \\H
    @close-brace
  }
  function @virtualenv() {
    test "$VIRTUAL_ENV" || return 0
    printf %s ' '
    @open-brace
    @color bold black
    printf %s 'venv'
    @color reset cyan
    printf %s ':'
    @color reset red
    # TODO: use smart relative path
    printf %s "${VIRTUAL_ENV/#$HOME/\~}"
    @color reset bold black
    @close-brace
  }
  function @token() {
    @color reset bold black
    printf %s '\$'
    @color reset
    printf %s ' '
  }

  ps1_start=$(
    @color reset
    printf %s "\["
    update_terminal_cwd
    @status-code "$last_exit_code"
    @history
    @user-host
  )

  ps1_end=$(
    printf %s \\n
    @open-brace
    @color green
    printf %s \\w
    @color reset
    @close-brace
    @color reset
    @virtualenv
    @token
  )

  # something in /etc/bashrc fucks with git prompt
  if [[ "$HOSTNAME" == *".facebook.com" ]]; then
    NO_GIT_PROMPT=1
  fi

  if [ -z "${NO_GIT_PROMPT:-}" ]; then
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWSTASHSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1
    export GIT_PS1_SHOWUPSTREAM="auto git"
    export GIT_PS1_SHOWCOLORHINTS=1

    local now later
    now=$(date +%s)
    if __git_ps1 "${ps1_start}" "${ps1_end}" "$(@open-brace)%s$(@close-brace)" 2> /dev/null; then
      later=$(date +%s)
      if [ $((later - now)) -gt 5 ]; then
        echo 'WARN: generating git prompt took longer than 5s. Automatically setting NO_GIT_PROMPT.' >&2
        @export NO_GIT_PROMPT 1
      elif [ $((later - now)) -gt 2 ]; then
        echo 'WARN: generating git prompt took longer than 2s. Consider setting NO_GIT_PROMPT.' >&2
      fi
      return 0
    fi
  fi

  export PS1="${ps1_start}${ps1_end}"
}

@export PROMPT_COMMAND "@set-prompt"
