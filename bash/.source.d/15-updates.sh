#!/usr/bin/env bash

function @update-brew() {
  if command -v brew &> /dev/null; then
    (brew update && brew upgrade && brew cleanup)
    brew bundle dump --file="$DOTFILES_PATH/Brewfile" --force &> /dev/null
  fi
}

function @update-npm() {
  __update() {
    local -r npm=${1:-npm}
    local -a pkgs
    mapfile -t pkgs < <("$npm" -g outdated --parseable --depth=0 | cut -d: -f4 | grep -v '@git$')
    if [[ ${#pkgs[@]} -gt 0 ]]; then
      "$npm" -g install "${pkgs[@]}"
    fi
  }

  if command -v nvm > /dev/null 2>&1; then
    # if nvm is in the environment, must use `nvm use`
    local current
    current=$(nvm current)
    for node in system "$HOME"/.nvm/versions/node/*; do
      node=$(basename "$node")
      nvm use "$node"
      __update
    done
    nvm use "$current"
  else
    # nvm can be installed, but not in the environment
    local npm
    for npm in /usr/local/bin/npm "$HOME"/.nvm/versions/node/*/bin/npm; do
      if [[ -x $npm ]]; then
        __update "$npm"
      fi
    done
  fi
}

function @update() {
  local USE_X
  case "$-" in
  *x*) USE_X="-x" ;;
  esac

  set -x

  @update-brew
  @update-npm

  if [ -z "$USE_X" ]; then
    set +x
  fi
}
