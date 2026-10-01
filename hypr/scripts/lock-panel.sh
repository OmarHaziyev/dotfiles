#!/bin/bash

STATE="$XDG_RUNTIME_DIR/hyprlock-panel-state"

[[ -f "$STATE" ]] || echo 0 > "$STATE"

mode="$(cat "$STATE" 2>/dev/null)"
[[ "$mode" =~ ^[0-2]$ ]] || mode=0

case "$1" in
    next)
        mode=$(( (mode + 1) % 3 ))
        echo "$mode" > "$STATE"
        pkill -USR2 hyprlock 2>/dev/null
        exit 0
        ;;

    prev)
        mode=$(( (mode + 2) % 3 ))
        echo "$mode" > "$STATE"
        pkill -USR2 hyprlock 2>/dev/null
        exit 0
        ;;

    title)
        case "$mode" in
            0) echo "MEDIA" ;;
            1) echo "NOTIFICATIONS" ;;
            2) echo "WEATHER" ;;
        esac
        ;;

    content)
        case "$mode" in
            0)
                if command -v playerctl >/dev/null 2>&1 &&
                   playerctl status >/dev/null 2>&1; then

                    artist="$(playerctl metadata --format '{{ artist }}' 2>/dev/null)"
                    song="$(playerctl metadata --format '{{ title }}' 2>/dev/null)"
                    status="$(playerctl status 2>/dev/null)"

                    if [[ -n "$artist" && -n "$song" ]]; then
                        echo "$artist  —  $song"
                    elif [[ -n "$song" ]]; then
                        echo "$song"
                    else
                        echo "Nothing playing"
                    fi
                else
                    echo "Nothing playing"
                fi
                ;;

            1)
                if command -v swaync-client >/dev/null 2>&1; then
                    count="$(swaync-client --count 2>/dev/null)"
                    count="${count:-0}"

                    if [[ "$count" == "1" ]]; then
                        echo "1 notification"
                    else
                        echo "$count notifications"
                    fi
                else
                    echo "Notifications unavailable"
                fi
                ;;

            2)
                city="$(curl -sL --max-time 3 https://ipapi.co/json/ 2>/dev/null |
                    jq -r '.city // empty' 2>/dev/null)"

                if [[ -z "$city" ]]; then
                    echo "Weather unavailable"
                    exit 0
                fi

                weather="$(curl -sL --max-time 5 \
                    "https://wttr.in/${city// /+}?format=j1" 2>/dev/null)"

                if [[ -z "$weather" ]]; then
                    echo "$city  •  Weather unavailable"
                    exit 0
                fi

                temp="$(echo "$weather" |
                    jq -r '(.data.current_condition[0] // .current_condition[0]).temp_C // empty' 2>/dev/null)"

                condition="$(echo "$weather" |
                    jq -r '(.data.current_condition[0] // .current_condition[0]).weatherDesc[0].value // empty' 2>/dev/null)"

                if [[ -n "$temp" && -n "$condition" ]]; then
                    echo "$city  •  ${temp}°C  •  $condition"
                else
                    echo "$city  •  Weather unavailable"
                fi
                ;;
        esac
        ;;

    icon)
        case "$mode" in
            0)
                status="$(playerctl status 2>/dev/null)"

                if [[ "$status" == "Playing" ]]; then
                    echo "󰏤"
                else
                    echo "󰐊"
                fi
                ;;

            1)
                echo "󰂚"
                ;;

            2)
                echo "󰖐"
                ;;
        esac
        ;;
esac