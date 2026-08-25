#!/bin/bash
# Starts/stops a screen recording with wf-recorder.
# Bound to the record icon in the SwayNC quick toggles row.
# Swap wf-recorder for whatever recorder you actually use if this isn't it.

OUT_DIR="$HOME/Videos/Recordings"
mkdir -p "$OUT_DIR"

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Screen Record" "Recording stopped"
else
    wf-recorder -f "$OUT_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4" &
    disown
    notify-send "Screen Record" "Recording started"
fi