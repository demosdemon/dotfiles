#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# .bash_profile is only sourced when bash is started as an interactive login shell or with `--login`

function @replicate() {
  seq "${1:-40}" | sed c\\$'\n'"${2:--}" || return $?
  echo
}

function @enable-xtrace() {
  # enable bash xtrace debugging out to file if trigger file found
  if [ "$BASH_XTRACEFD" ]; then
    # xtrace already outputting to a file descriptor
    # TODO: validate fd, print message
    set -x
  else
    logfile=.bash_xtrace_$(date +%Y%m%d%H%M%S)_${BASHPID}.log
    BASH_XTRACE_LOGFILE=${HOME}/$logfile
    set >> "${BASH_XTRACE_LOGFILE}"
    exec {BASH_XTRACEFD}>> "${BASH_XTRACE_LOGFILE}"

    {
      @replicate $COLUMNS '='
      echo 'Enabling bash xtrace!'
      echo 'Use "@disable-xtrace" to disable.'
      echo "logfile: \${BASH_XTRACE_LOGFILE}=~/${logfile}"
      @replicate $COLUMNS '='
    } >&2

    unset logfile

    set -x
  fi

  function @disable-xtrace() {
    set +x
    exec {BASH_XTRACEFD}>&-
    unset BASH_XTRACEFD
    unset -f @disable-xtrace
  }

  export -f @disable-xtrace
}

if [ "$BASH" ] && [ -f "${HOME}/.bash_xtrace" ]; then
  @enable-xtrace
fi

# shim `realpath` in environments without, i.e., default macos
if ! command -v realpath > /dev/null 2>&1; then
  function realpath() {
    /usr/bin/python -c 'import sys, os; print(os.path.realpath(sys.argv[1]));' "$1"
  }

  export -f realpath
fi

function @import() {
  if ! (($#)); then
    @error "usage: @import <file> [file] [file]..."
    return 1
  fi

  while (($#)); do
    if [ -e "$1" ]; then
      source "$1"
    fi
    shift
  done
}

# restrict imports to only *.sh files
@import "${HOME}/.source.d"/*.sh
