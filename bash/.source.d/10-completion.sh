#!/usr/bin/env bash

if [ -n "$BREW_PREFIX" ] && [ -d "$BREW_PREFIX/etc/bash_completion.d" ]; then
  @export BASH_COMPLETION_COMPAT_DIR "$BREW_PREFIX/etc/bash_completion.d"
fi

# Add tab completion for many Bash commands
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/etc/bash_completion" ]; then
  @import "$BREW_PREFIX/etc/bash_completion"
elif [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/share/bash-completion/bash_completion" ]; then
  @import "$BREW_PREFIX/share/bash-completion/bash_completion"
elif [ -f /etc/bash_completion ]; then
  @import /etc/bash_completion
fi

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &> /dev/null && [ -f /usr/local/etc/bash_completion.d/git-completion.bash ]; then
  complete -o default -o nospace -F _git g
fi

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
# TODO: .app_completions
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

complete -C /usr/local/bin/vault vault
