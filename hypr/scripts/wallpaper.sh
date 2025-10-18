#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Douments/Wallpapers/"
CURRENT_WALL=$(hyprctl hyprpaper listloaded)

while true; do
  sleep 60
  # Get a random wallpaper that is not the current one
  WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
  # Apply the selected wallpaper
  hyprctl hyprpaper reload ,"$WALLPAPER"
done
