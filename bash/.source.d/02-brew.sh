#!/usr/bin/env bash

@prepend-path PATH "${HOME}/homebrew/bin"

[ "$BREW" ] || @export BREW "$(command -v brew)"

if [ "$BREW" ]; then
  [ "$BREW_PREFIX" ] || @export BREW_PREFIX "$("$BREW" --prefix 2> /dev/null)"
fi

if [ "$BREW_PREFIX" ]; then
  @import "${BREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
  @import "${BREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
  @import "${BREW_PREFIX}/opt/nvm/nvm.sh"
fi
