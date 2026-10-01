#!/bin/bash
# Custom battery module — reads sysfs directly on every poll instead of
# Waybar's built-in battery/upower binding, which has a known race that
# leaves the charging icon one toggle behind the real AC state.

BAT=$(ls /sys/class/power_supply | grep -m1 '^BAT')
[ -z "$BAT" ] && { echo '{"text":"","tooltip":"No battery"}'; exit 0; }

BASE="/sys/class/power_supply/$BAT"
capacity=$(cat "$BASE/capacity" 2>/dev/null)
status=$(cat "$BASE/status" 2>/dev/null)   # Charging / Discharging / Full / Not charging

icons=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
idx=$(( capacity / 10 ))
[ "$idx" -gt 9 ] && idx=9
icon="${icons[$idx]}"

class=""
[ "$capacity" -le 30 ] && class="warning"
[ "$capacity" -le 15 ] && class="critical"
[ "$status" = "Charging" ] && class="charging"

case "$status" in
    Charging)
        text="󰂄 ${capacity}%"
        ;;
    "Not charging"|Full)
        text="󰚥 ${capacity}%"
        ;;
    *)
        text="${icon} ${capacity}%"
        ;;
esac

echo "{\"text\":\"${text}\",\"class\":\"${class}\",\"tooltip\":\"${capacity}% — ${status}\"}"