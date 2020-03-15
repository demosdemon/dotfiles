#!/usr/bin/env bash

if [ "$BREW" ] && command -v jq > /dev/null; then
  function @update-pkg-config-path() {
    echo -n 'Caching PKG_CONFIG_PATH... '
    local dir keg
    local -a res
    for keg in $("$BREW" info --json=v1 --installed | jq -M -r -c "map(select(.key_only == true and .linked_keg == null) | .name) | .[]"); do
      if dir="$(brew --prefix "$keg")/lib/pkgconfig"; then
        if [ -d "$dir" ]; then
          res+=("$dir")
        fi
      fi
    done

    @join : "${res[@]}" > "${HOME}/.pkg_config_path_cache"
    echo 'Done!'
  }

  if [ -f "${HOME}/.pkg_config_path_cache" ] && [ "$(($(date +%s) - $(/usr/bin/stat -f %m "${HOME}/.pkg_config_path_cache")))" -le $((6 * 24 * 60 * 60)) ]; then
    true
  elif [ -f "${HOME}/.pkg_config_path_cache" ] && [ "$(($(date +%s) - $(/usr/bin/stat -f %m "${HOME}/.pkg_config_path_cache")))" -le $((7 * 24 * 60 * 60)) ]; then
    echo 'WARN: PKG_CONFIG_PATH will expire in <24h' >&2
    true
  else
    @update-pkg-config-path
  fi

  # shellcheck disable=SC2046
  @prepend-path PKG_CONFIG_PATH $(@split ':' "$(< "${HOME}/.pkg_config_path_cache")")
fi
