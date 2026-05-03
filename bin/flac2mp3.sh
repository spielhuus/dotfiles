#!/usr/bin/env bash
set -uo pipefail

# Safe glob expansion: prevents *.flac from expanding to the literal string if none exist
shopt -s nullglob
flac_files=( *.flac )

if [[ ${#flac_files[@]} -eq 0 ]]; then
    echo "No .flac files found in the current directory."
    exit 0
fi

# Check for cover art once before the loop
has_cover=false
if [[ -f cover.jpg ]]; then
    has_cover=true
    echo "Found cover.jpg. Album art will be embedded."
else
    echo "cover.jpg not found. Converting without album art."
fi

for f in "${flac_files[@]}"; do
    out="${f%.flac}.mp3"

    # Skip if output already exists to prevent overwriting or redundant work
    if [[ -f "$out" ]]; then
        echo "Skipping '$f' (output already exists)"
        continue
    fi

    echo -n "Converting '$f' -> '$out' ... "

    # Build ffmpeg command conditionally
    if $has_cover; then
        ffmpeg -nostdin -i "$f" -i cover.jpg \
            -map 0:a -map 1:v \
            -c:a libmp3lame -q:a 0 \
            -id3v2_version 3 \
            -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
            "$out" -loglevel error
    else
        ffmpeg -nostdin -i "$f" \
            -c:a libmp3lame -q:a 0 \
            -id3v2_version 3 \
            "$out" -loglevel error
    fi

    # Only delete the source if conversion succeeded
    if [[ $? -eq 0 ]]; then
        echo "OK. Removing source FLAC."
        rm -- "$f"
    else
        echo "FAILED. Source FLAC kept." >&2
    fi
done

# Safe cleanup: only remove cover.jpg if it actually exists
if [[ -f cover.jpg ]]; then
    rm -- cover.jpg
    echo "Cleaned up cover.jpg"
fi

echo "Conversion complete."
