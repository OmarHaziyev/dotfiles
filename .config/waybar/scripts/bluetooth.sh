#!/bin/bash

if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo '{"text":"󰂲 Off","tooltip":"Bluetooth disabled","class":"disabled"}'
    exit 0
fi

connected=$(bluetoothctl devices Connected | head -n 1)

if [ -n "$connected" ]; then
    name=$(echo "$connected" | cut -d' ' -f3-)
    echo "{\"text\":\"󰂯 ${name}\",\"tooltip\":\"Connected: ${name}\",\"class\":\"connected\"}"
else
    echo '{"text":"󰂯 On","tooltip":"Bluetooth on — no device connected","class":"on"}'
fi