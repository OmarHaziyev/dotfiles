#!/bin/bash
# Wallpaper picker + retheme, bound to SUPER + SHIFT + W.

WALL_DIR="$HOME/Pictures/Wallpapers"
THUMB_DIR="$HOME/.cache/rofi-wallpapers"

mkdir -p "$THUMB_DIR"

# Generate thumbnails for any new wallpapers (cached, so instant after first run)
find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0 |
while IFS= read -r -d '' img; do
    name=$(basename "$img")
    thumb="$THUMB_DIR/$name"
    [ -f "$thumb" ] || magick "$img" -thumbnail 400x225^ -gravity center -extent 400x225 "$thumb"
done

entries=""
while IFS= read -r name; do
    thumb="$THUMB_DIR/$name"
    entries+="${name%.*}\0icon\x1f$thumb\n"
done < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%f\n" | sort)

selected=$(echo -e "$entries" | rofi -dmenu -i -show-icons -p "  Wallpaper" -theme ~/.config/rofi/wallpaper.rasi)

[ -z "$selected" ] && exit 0

# Match selection back to full filename (with extension) since display strips it
full_name=$(find "$WALL_DIR" -maxdepth 1 -type f -iname "${selected}.*" -printf "%f\n" | head -n1)

matugen image "$WALL_DIR/$full_name" --mode dark --source-color-index 0