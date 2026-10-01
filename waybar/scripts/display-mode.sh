#!/bin/bash
# Windows+P style display-mode switcher for Hyprland.
# Bound to SUPER + P.
#
# Assumes a laptop panel (eDP-*) plus one external monitor. If you run
# multiple externals, this picks the first one it finds as "the"
# external — flag it and we can extend this to a picker if needed.

monitors_json=$(hyprctl monitors -j)

INTERNAL=$(echo "$monitors_json" | jq -r '.[] | select(.name | test("eDP")) | .name' | head -n1)
mapfile -t EXTERNALS < <(echo "$monitors_json" | jq -r --arg internal "$INTERNAL" \
    '.[] | select(.name != $internal) | .name')

if [ -z "$INTERNAL" ] || [ "${#EXTERNALS[@]}" -eq 0 ]; then
    notify-send "Display" "No external monitor detected."
    exit 0
fi

EXTERNAL="${EXTERNALS[0]}"

get_mode() {
    echo "$monitors_json" | jq -r --arg name "$1" \
        '.[] | select(.name==$name) | "\(.width)x\(.height)@\(.refreshRate|round)"'
}
get_width() {
    echo "$monitors_json" | jq -r --arg name "$1" '.[] | select(.name==$name) | .width'
}

INT_MODE=$(get_mode "$INTERNAL")
EXT_MODE=$(get_mode "$EXTERNAL")
INT_WIDTH=$(get_width "$INTERNAL")

options="󰌢  PC screen only\n󰍹  Duplicate\n󰍺  Extend\n󰍹  Second screen only"

selected=$(echo -e "$options" | rofi -dmenu -i -p "Display Mode" -theme ~/.config/rofi/theme.rasi)

case "$selected" in
    *"PC screen only"*)
        hyprctl keyword monitor "$EXTERNAL,disable"
        hyprctl keyword monitor "$INTERNAL,$INT_MODE,0x0,1"
        ;;
    *"Duplicate"*)
        hyprctl keyword monitor "$INTERNAL,$INT_MODE,0x0,1"
        hyprctl keyword monitor "$EXTERNAL,$EXT_MODE,0x0,1,mirror,$INTERNAL"
        ;;
    *"Extend"*)
        hyprctl keyword monitor "$INTERNAL,$INT_MODE,0x0,1"
        hyprctl keyword monitor "$EXTERNAL,$EXT_MODE,${INT_WIDTH}x0,1"
        ;;
    *"Second screen only"*)
        hyprctl keyword monitor "$INTERNAL,disable"
        hyprctl keyword monitor "$EXTERNAL,$EXT_MODE,0x0,1"
        ;;
    *)
        exit 0
        ;;
esac

notify-send "Display" "Switched: ${selected#* }"