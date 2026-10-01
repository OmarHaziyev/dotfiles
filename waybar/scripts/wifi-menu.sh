#!/bin/bash
# Async Wi-Fi picker: opens rofi immediately with cached networks,
# then streams in newly discovered networks live as a background
# rescan completes — no more blocking the menu on the rescan.
#
# Also detects WPA2-Enterprise (802.1X) networks and prompts for a
# username in addition to a password when needed (e.g. school wifi).

IFACE="wlan0"
FIFO=$(mktemp -u /tmp/wifi-menu.XXXXXX.fifo)
mkfifo "$FIFO"

list_networks() {
nmcli -t -f SSID,SIGNAL,SECURITY device wifi list ifname "$IFACE" --rescan no 2>/dev/null \
| awk -F: '$1 != "" {print $1 "\t" $2 "%"}' \
| awk -F'\t' '!seen[$1]++'
}

# Look up the SECURITY field for a given SSID from the current scan cache.
get_security() {
    local ssid="$1"
    nmcli -t -f SSID,SECURITY device wifi list ifname "$IFACE" --rescan no 2>/dev/null \
        | awk -F: -v s="$ssid" '$1 == s {sub(/^[^:]*:/, ""); print; exit}'
}

(
declare -A shown

# cached results first — instant
while IFS=$'\t' read -r ssid signal; do
        [ -n "$ssid" ] || continue
shown["$ssid"]=1
printf '%s\t%s\n' "$ssid" "$signal"
done < <(list_networks)

nmcli device wifi rescan ifname "$IFACE" 2>/dev/null

# poll briefly for fresh results, appending only new SSIDs
for _ in $(seq 1 10); do
sleep 0.5
while IFS=$'\t' read -r ssid signal; do
            [ -n "$ssid" ] || continue
if [ -z "${shown[$ssid]:-}" ]; then
shown["$ssid"]=1
printf '%s\t%s\n' "$ssid" "$signal"
fi
done < <(list_networks)
done
) > "$FIFO" &
FEEDER_PID=$!

selected=$(rofi -dmenu -i -p "󰤨  Wi-Fi" -theme ~/.config/rofi/theme.rasi < "$FIFO")

kill "$FEEDER_PID" 2>/dev/null
rm -f "$FIFO"

[ -z "$selected" ] && exit 0

SSID=$(echo "$selected" | cut -f1)

# Already have a saved connection profile for this SSID? Just bring it up.
if nmcli connection show "$SSID" >/dev/null 2>&1; then
nmcli connection up "$SSID"
exit 0
fi

# Figure out what kind of auth this network needs.
SECURITY=$(get_security "$SSID")

if echo "$SECURITY" | grep -q "802.1X"; then
    # --- WPA2/WPA3-Enterprise: needs identity + password ---
    username=$(rofi -dmenu -p "󰀄  Username" -theme ~/.config/rofi/theme.rasi)
    [ -z "$username" ] && exit 0

    password=$(rofi -dmenu -password -p "󰌆  Password" -theme ~/.config/rofi/theme.rasi)
    [ -z "$password" ] && exit 0

    # Build a dedicated enterprise connection profile.
    # peap/mschapv2 covers the vast majority of school/enterprise networks
    # (eduroam included). Adjust 802-1x.eap / phase2-auth if yours differs.
    nmcli connection add \
        type wifi \
        con-name "$SSID" \
        ifname "$IFACE" \
        ssid "$SSID" \
        wifi-sec.key-mgmt wpa-eap \
        802-1x.eap peap \
        802-1x.phase2-auth mschapv2 \
        802-1x.identity "$username" \
        802-1x.password "$password" >/dev/null 2>&1

    nmcli connection up "$SSID"

elif echo "$SECURITY" | grep -qE "WPA|WEP"; then
    # --- Standard WPA/WPA2-Personal: password only ---
    password=$(rofi -dmenu -password -p "󰌆  Password" -theme ~/.config/rofi/theme.rasi)
    [ -z "$password" ] && exit 0

    nmcli device wifi connect "$SSID" password "$password" ifname "$IFACE"

else
    # --- Open network: no credentials needed ---
    nmcli device wifi connect "$SSID" ifname "$IFACE"
fi

if [ $? -eq 0 ]; then
notify-send "Wi-Fi" "Connected to $SSID"
else
notify-send "Wi-Fi" "Failed to connect to $SSID"
fi