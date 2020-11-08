#!/usr/bin/env bash

query="$1"
script="${XDG_CONFIG_HOME:-${HOME}/.config}/mutt/scripts/address-query.sh"
term="${TERMINAL:-/usr/bin/x-terminal-emulator}"
pipe="${XDG_RUNTIME_DIR}/address-query/address-query-$$.pipe"

cleanup() {
    rm "$pipe"
}

mkdir -p "$(dirname $pipe)"
mkfifo "$pipe"

trap "cleanup" EXIT

$term --class fzf_xfloating -e bash -c "exec -a bash $script '$query' >$pipe" &

echo
while true; do
    if read line <$pipe; then
        if [ "$line" == "eof" ]; then
            break
        fi
        echo -n "$line, "
    fi
done

