#!/bin/bash
# Waybar custom module: shows an airplane icon while wifi is rfkill
# soft-blocked (airplane mode); outputs empty text otherwise, which
# Waybar treats as "hide this module".

if command -v jq >/dev/null 2>&1 && rfkill --json list wifi >/dev/null 2>&1; then
    soft=$(rfkill --json list wifi | jq -r '.rfkilldevices[0].soft // empty')
else
    if rfkill list wifi | grep -q "Soft blocked: yes"; then
        soft="blocked"
    else
        soft="unblocked"
    fi
fi

if [ "$soft" = "blocked" ]; then
    echo '{"text":"󰀝","tooltip":"Airplane mode on — click to disable","class":"airplane"}'
else
    echo '{"text":"","tooltip":""}'
fi