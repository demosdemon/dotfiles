#!/usr/bin/env bash

[ "$BREW" ] || @export BREW "$(command -v brew)"

if [ "$BREW" ]; then
  [ "$BREW_PREFIX" ] || @export BREW_PREFIX "$("$BREW" --prefix 2> /dev/null)"
fi
