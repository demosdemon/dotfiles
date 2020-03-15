#!/usr/bin/env bash

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
  local loc

  loc=$(
    osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)'
  )

  if [ -n "$loc" ]; then
    cd "$loc" || return $?
  else
    return 1
  fi

  return 0
}
