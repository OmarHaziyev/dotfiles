#!/usr/bin/env bash
#
# Rofi clipboard history via cliphist
# Requires: cliphist, wl-clipboard
#
# Usage as a rofi custom mode (already wired in config.rasi):
#   rofi -show clipboard -modi clipboard:~/.config/rofi/scripts/clipboard.sh
#
# Rofi calls this script twice: once with no args to populate the list,
# once with the selected line as $1 to act on it.

if [ -z "$1" ]; then
    cliphist list
else
    echo "$1" | cliphist decode | wl-copy
fi