#!/usr/bin/env bash

for f in *.flac; do
    ffmpeg -i "$f" -i cover.jpg \
    -map 0:a -map 1:v \
    -c:a libmp3lame -q:a 0 \
    -id3v2_version 3 \
    -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
    "${f%.flac}.mp3"
done

rm *.flac
rm *.jpg
