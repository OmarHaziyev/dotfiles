#!/bin/bash

IFACE="wlan0"

nmcli device wifi rescan ifname "$IFACE" 2>/dev/null
sleep 1

networks=$(nmcli -t -f SSID,SIGNAL,SECURITY device wifi list ifname "$IFACE" \
    | awk -F: '$1 != "" {print $1 "\t" $2 "%"}' \
    | awk -F'\t' '!seen[$1]++')

[ -z "$networks" ] && exit 1

selected=$(printf '%s\n' "$networks" | \
    rofi -dmenu \
    -i \
    -p "󰤨  Wi-Fi" \
    -theme ~/.config/rofi/theme.rasi)

[ -z "$selected" ] && exit 0

SSID=$(echo "$selected" | cut -f1)

# Existing saved connection
if nmcli connection show "$SSID" >/dev/null 2>&1; then
    nmcli connection up "$SSID"
    exit 0
fi

# Ask for password graphically
password=$(rofi -dmenu \
    -password \
    -p "󰌆  Password" \
    -theme ~/.config/rofi/theme.rasi)

[ -z "$password" ] && exit 0

nmcli device wifi connect "$SSID" password "$password" ifname "$IFACE"

if [ $? -eq 0 ]; then
    notify-send "Wi-Fi" "Connected to $SSID"
else
    notify-send "Wi-Fi" "Failed to connect to $SSID"
fi