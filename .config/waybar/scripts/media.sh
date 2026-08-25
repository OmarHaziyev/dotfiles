#!/usr/bin/env bash
#
# Waybar custom/media module — any MPRIS player (Spotify, browser tabs,
# VLC, etc.), not just Spotify. Requires: playerctl
#
# Usage:
#   media.sh          -> prints waybar JSON status
#   media.sh toggle    -> play/pause active player
#   media.sh next       -> skip active player
#   media.sh prev        -> previous track on active player

get_active_player() {
    local p
    for p in $(playerctl -l 2>/dev/null); do
        if [ "$(playerctl -p "$p" status 2>/dev/null)" = "Playing" ]; then
            echo "$p"
            return
        fi
    done
    playerctl -l 2>/dev/null | head -n1
}

player=$(get_active_player)

case "$1" in
    toggle) [ -n "$player" ] && playerctl -p "$player" play-pause; exit 0 ;;
    next)   [ -n "$player" ] && playerctl -p "$player" next; exit 0 ;;
    prev)   [ -n "$player" ] && playerctl -p "$player" previous; exit 0 ;;
esac

if [ -z "$player" ]; then
    echo '{"text":"󰝛  nothing playing","tooltip":"No media player active","class":"stopped"}'
    exit 0
fi

status=$(playerctl -p "$player" status 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null)

if [ "$status" = "Playing" ]; then
    icon="󰐊"; class="playing"
else
    icon="󰏤"; class="paused"
fi

raw="${artist:-Unknown} - ${title:-Unknown}"
trimmed=$(echo "$raw" | cut -c1-38)
text=$(echo "${icon}  ${trimmed}" | sed 's/"/\\"/g')
tooltip=$(echo "${raw} (${player})" | sed 's/"/\\"/g')

echo "{\"text\":\"${text}\",\"tooltip\":\"${tooltip}\",\"class\":\"${class}\"}"