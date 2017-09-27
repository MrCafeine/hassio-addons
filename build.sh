#!/usr/bin/env bash

set -e

cd "$(readlink -f "$(dirname "$0")")" || exit 9

usage() {
  echo "Usage: $(basename "$0") ADDON [ARCH]"
}

addon_list() {
  local dir
  for dir in */config.json
  do
    dirname "$dir"
  done
}

build_addon() {
  cd "$1" || exit 8
  local target
  if [[ -n "$2" ]]
  then
    target="$2"
  else
    target=all
  fi
  docker run --rm --privileged \
    -v ~/.docker:/root/.docker \
    -v "$PWD:/data" \
    homeassistant/amd64-builder \
    --$target -t /data
  cd -
}

ADDONS=$(addon_list)

if [[ "$1" == all ]]
then
  for addon in $ADDONS
  do
    build_addon "$addon" "$2"
  done
elif [[ $1 =~ "help" ]]
then
  usage
  exit 0
elif grep -q "$1" <<< "$ADDONS"
then
  build_addon "$1" "$2"
else
  usage
  exit 2
fi

# vim: set ft=sh et ts=2 sw=2 :