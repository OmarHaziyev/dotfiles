#!/usr/bin/env bash

cliphist list \
    | rofi -dmenu \
        -display-columns 2 \
        -p "Clipboard" \
    | cliphist decode \
    | wl-copy