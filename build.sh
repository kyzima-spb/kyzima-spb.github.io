#!/usr/bin/env bash
set -e

ROOT_DIR=$(dirname "$(readlink -f "$0")")

command pushd "$ROOT_DIR/src"
    files=$(find . -type f | sed 's~^./~https://kyzima-spb.github.io/src/~')
    result=""

    for url in $files; do
      result+="<li><a href=\"$url\">$(basename "$url")</a></li>"
    done

    sed -r -e 's~<% links %>~'"$result"'~' "../index.tmpl" > "../index.html"
command popd
