#!/usr/bin/env bash

function isort-black() { isort -rc "$@" && black --line-length 120 "$@"; }

function update-docker-images() {
  for img in $(docker images --format '{{ .Repository }}:{{ .Tag }}' | grep -v -F -e '<none>'); do docker pull "$img"; done
}

function total-mem() {
  sysctl -a | grep -F 'hw.memsize' | cut -d' ' -f2
}

function coffee-fmt() {
  local file=$1 tmpfile
  tmpfile=$(mktemp)
  NODE_OPTIONS=--max-old-space-size=$(($(total-mem) / 1024 / 1024 / 2)) \
    command coffee-fmt --indent_style space --indent_size 4 -i "$file" > "$tmpfile" &&
    mv -f "$tmpfile" "$file"
}

# Compare original and gzipped file size
function gz() {
  if [ $# -eq 0 ]; then
    echo 'usage: gz <FILENAME>'
    return 1
  fi
  if ! [ -f "$1" ]; then
    echo "gz: $1: no such file or directory"
    return 1
  fi

  local origsize=$(wc -c < "$1")
  local gzipsize=$(gzip -c "$1" | wc -c)
  local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
  printf "orig: %d bytes\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
  if [ -t 0 ]; then # argument
    python -mjson.tool <<< "$*" | pygmentize -l javascript
  else # pipe
    python -mjson.tool | pygmentize -l javascript
  fi
}

# Run `dig` and display the most useful info
function digga() {
  dig +nocmd "$1" any +multiline +noall +answer
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
  if [ $# -eq 0 ]; then
    open .
  else
    open "$@"
  fi
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
  tree -aC -I '\.git|\.venv|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Outputs the relative path of the first parameter to the second, default is pwd
# e.g.:
#   $ relpath $HOME/Documents $HOME
#   Documents
function relpath() {
  python -c "
from os.path import abspath, relpath;
from sys import argv;

dest = abspath(argv[1]);
source = abspath(argv[2]);

print(relpath(dest, source));
" "$1" "${2-$PWD}"
}

function gs() {
  local GS=$(which gs)
  if [[ -n $GS && $# -gt 0 ]]; then
    $GS "$@" # params means I probably want ghost script
  else
    g s
  fi
}

function dumpdb() {
  if [ $# -eq 0 ]; then
    echo "dumpdb: <dbname>"

    return 1
  fi

  pg_dump --clean --if-exists --create --encoding=utf8 \
    --file="${1}_dump.sql" --format=plain --no-owner \
    --verbose "${1}"

  xz -9e --verbose "${1}_dump.sql"
}

function code() {
  local bundle="com.microsoft.VSCode"

  VSCODE_CWD="$PWD" open -b "$bundle" -n --args "$@"
}

function killall_osx() {
  for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" \
    "cfprefsd" "Dock" "Finder" "Mail" "Messages" "Safari" "SizeUp" \
    "SystemUIServer" "Terminal" "Transmission" "Twitter" "iCal"; do
    killall "${app}" > /dev/null 2>&1
  done
}

function reset_wifi() {
  if [[ $EUID -ne 0 ]]; then
    sudo bash -c "$(declare -f reset_wifi); reset_wifi $*"
    return $?
  fi

  sleep=${1:-2}

  ifconfig en0 down &&
    sleep 2 &&
    route flush &&
    sleep "$sleep" &&
    ifconfig en0 up
}

function rand_string() {
  chars=${1:-32}
  charset='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&'\''()*+,-./:;<=>?@[\\]^_`{|}~'
  charset=${2:-"$charset"}
  cat /dev/urandom | tr -dc "$charset" | fold -w $chars | head -n 1
}

function rand_int() {
  digits=${1:-8}
  cat /dev/urandom | tr -dc '0-9' | fold -w 256 | sed -e 's/^0*//' | head --bytes $digits
  echo ''
}

function serve() {
  if [ "$1" ]; then
    if [ -e "$1" ]; then
      dir="$1"
      shift
    else
      dir=$PWD
    fi
    if [ "$1" ]; then
      port="$1"
    else
      port=8080
    fi
  else
    port=8080
    dir=$PWD
  fi

  python3 -m http.server --directory "$dir" "$port"
}

function video-url-from-tweet() {
  if [ "$1" ]; then
    url=$1
  else
    echo "Must provide a url"
    return 1
  fi

  curl --silent $url |

    # should find the <meta> tag with content="<thumbnail url>"
    (grep -m1 "ext_tw_video_thumb" ||
      echo "Could not find video" && return 1) |

    # from: <meta property="og:image" content="https://pbs.twimg.com/tweet_video_thumb/xxxxxxxxxx.jpg">
    # to: https://pbs.twimg.com/tweet_video_thumb/xxxxxxxxxx.jpg
    cut -d '"' -f 4 |

    # from: https://pbs.twimg.com/tweet_video_thumb/xxxxxxxxxx.jpg
    # to: https://video.twimg.com/tweet_video/xxxxxxxxxx.mp4
    sed 's/.jpg/.m3u8/g' |
    sed 's/pbs.twimg.com\/ext_tw_video_thumb/video.twimg.com\/ext_tw_video/g'
}

function video-from-tweet() {
  if [ "$1" ]; then
    url=$1
  else
    echo "Must provide a url"
    return 1
  fi
  curl $(video-url-from-tweet $url)
}

function video-to-gif() {
  # derived from https://engineering.giphy.com/how-to-make-gifs-with-ffmpeg/
  if [ "$2" ]; then
    input=$1
    output=$2
  else
    echo "Must provide an input file and output file"
    return 1
  fi

  ffmpeg -i $input \
    -filter_complex "[0:v] split [a][b];[a] palettegen [p];[b][p] paletteuse" \
    -f gif \
    $output
}

function gif-from-tweet() {
  if [ "$2" ]; then
    url=$1
    output=$2
  else
    echo "Must provide a url and an output filename"
    return 1
  fi
  video-from-tweet $url | video-to-gif - $output
}

function xzrm() {
  if [ "$1" ]; then
    source=$1
  else
    echo "Usage: xzrm <source> [dest]"
    return 1
  fi

  dir=$(dirname "$source")
  base=$(basename "$source")

  if [ "$2" ]; then
    dest=$2
  else
    dest=$dir
  fi

  workdir=$(mktemp -d)
  tarfile="${base}.tar"
  xzfile="${tarfile}.xz"

  tar -vcf "${workdir}/${tarfile}" -C "$dir" "$base" &&
    xz -v9e "${workdir}/${tarfile}" &&
    rm -vrf "$source" &&
    mv -v "${workdir}/${xzfile}" "$dest"

  rmdir -v "$workdir"
}
