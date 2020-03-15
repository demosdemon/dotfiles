#!/usr/bin/env bash

@export GPG_TTY "$(tty)"

if [[ $SSH_AUTH_SOCK == /private/tmp/com.apple.launchd.*/Listeners ]]; then
  unset SSH_AUTH_SOCK # fucking apple getting in my way
fi

if [[ $SSH_AUTH_SOCK && -S $SSH_AUTH_SOCK ]]; then
  # we already have a socket, don't overwrite it
  true
else
  gpg-connect-agent updatestartuptty /bye > /dev/null 2>&1 || true

  function @setup-ssh-agent() {
    local socket
    if socket=$(gpgconf --list-dirs agent-ssh-socket); then
      @export SSH_AUTH_SOCK "$socket"
      unset SSH_AGENT_PID
    fi
  }

  @setup-ssh-agent
  unset -f @setup-ssh-agent
fi
