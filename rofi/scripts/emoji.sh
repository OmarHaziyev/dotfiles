#!/usr/bin/env bash
# Rofi emoji picker — copies AND types the emoji directly into
# whatever window had focus before the picker opened.
# Requires: rofimoji, wl-clipboard, wtype

selected=$(rofimoji \
    --action print \
    --files emojis \
    --selector-args "-theme $HOME/.config/rofi/theme.rasi")

[ -z "$selected" ] && exit 0

printf '%s' "$selected" | wl-copy
sleep 0.1
printf '%s' "$selected" | wtype -



