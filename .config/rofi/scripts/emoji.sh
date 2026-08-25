#!/usr/bin/env bash
#
# Rofi emoji picker
# Requires: rofimoji  (sudo pacman -S rofimoji)
#
# rofimoji already ships its own picker UI this just forces it to use
# your shared rofi theme instead of its own default styling, and copies
# the selected emoji straight to the clipboard.

rofimoji \
    --action copy \
    --files emojis \
    --selector-args "-theme /home/omar/.config/rofi/theme.rasi"