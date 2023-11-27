#!/usr/bin/env bash

query="$1"
address_cache="${XDG_CACHE_HOME:-${HOME}/.cache}/notmuch-addresses/address-cache.json"

# get terminal color escapes
name="$(tput setaf 3)"
brackets="$(tput setaf 5)"
reset="$(tput sgr0)"

regexp="s/^(.+\s)?<(.+)>$/${name}\1${reset}${brackets}<${reset}\2${brackets}>${reset}/"

# execcute search
jq -r '.[] | "\(."name-addr")" ' \
      ${address_cache} | \
sed -E ${regexp} | \
fzf --query "$query" \
    --no-height \
    --no-border \
    --multi \
    --prompt "@: " \
    --ansi \
    --preview 'echo {+} | sed -E "s/>\s/>\n/g"'

echo "eof"
