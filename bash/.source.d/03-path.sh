#!/usr/bin/env bash

# start fresh, on osx path_helper is called from /etc/profile
if [ -x /usr/libexec/path_helper ]; then
  eval "$(MANPATH='' PATH='' /usr/libexec/path_helper -s)"
fi

# Working bottom up because we're prepending to the path. Least significant
# goes first.

if [ "$JAVA_HOME" ]; then
  @prepend-path PATH "$JAVA_HOME/bin"
  @prepend-path MANPATH "$JAVA_HOME/man"
fi

@import-brew() {
  local -r -a bins=(
    sbin
    bin
    gnubin
  ) opts=(
    bison
    coreutils/libexec
    curl
    findutils/libexec
    gettext
    gnu-getopt
    gnu-sed/libexec
    openssl
    python
    python/libexec
    mongodb@3.6
  ) mans=(
    man
    gnuman
    share/man
    ../share/man
  )

  for bin in "${bins[@]}"; do
    @prepend-path PATH "$BREW_PREFIX/$bin"
  done

  for man in "${mans[@]}"; do
    @prepend-path MANPATH "$BREW_PREFIX/$man"
  done

  for pkg in "${opts[@]}"; do
    for bin in "${bins[@]}"; do
      @prepend-path PATH "$BREW_PREFIX/opt/$pkg/$bin"
    done

    for man in "${mans[@]}"; do
      @prepend-path MANPATH "$BREW_PREFIX/opt/$pkg/$man"
    done
  done
}

[ "$BREW_PREFIX" ] && @import-brew
unset -f @import-brew

@prepend-path PATH "$GOPATH/bin"
@prepend-path PATH "$HOME"/Library/Python/*/bin
@prepend-path PATH /opt/perl5/bin
@prepend-path PATH "$HOME/bin"
@prepend-path PATH "$HOME/.local/bin"
@prepend-path PATH "$HOME/.cabal/bin"
@prepend-path PATH "$HOME/.cargo/bin"

export PATH
export MANPATH
