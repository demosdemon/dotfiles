#!/usr/bin/env bash

export MONO_GAC_PREFIX="/usr/local"
export EDITOR='nano'

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export LESS="-iswRFX"

# Less Colors for Man Pages
# https://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages
# Ret: 2016-02-25
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -XF~"

@export GIT_AUTHOR_NAME "$(git config user.name 2> /dev/null)"
@export GIT_COMMITTER_NAME "$GIT_AUTHOR_NAME"
@export GIT_AUTHOR_EMAIL "$(git config user.email 2> /dev/null)"
@export GIT_COMMITTER_EMAIL "$GIT_AUTHOR_EMAIL"

export HUE_API="https://www.meethue.com/api/nupnp"

export PERL5LIB="/opt/perl5/lib/perl5"
export PERL_MB_OPT='--install_base "/opt/perl5"'
export PERL_MM_OPT="INSTALL_BASE=/opt/perl5"

export MONO_MANAGED_WATCHER=disabled

if [[ $(uname -s) == Darwin ]]; then
  if [ -d "$(/usr/bin/readlink /Library/Developer/Toolchains/swift-latest.xctoolchain)" ]; then
    export TOOLCHAINS=swift
  fi
fi

export PIPENV_VENV_IN_PROJECT=1
