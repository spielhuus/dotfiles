#!/bin/sh

if pgrep swaybg; then
	pkill swaybg
fi
swaybg -m fill -i ~/.cache/wallpaperwaybg -m fill -i ~/.cache/wallpaper
