#!/bin/bash
# convert_parallel.sh - параллельная конвертация

mkdir -p converted

# Функция конвертации
convert_task() {
    local input="$1"
    local output="converted/${input%.*}_x265.mp4"

    ffmpeg -i "$input" -c:v libx265 -preset slower -crf 18 -c:a copy -y -hide_banner -loglevel error "$output"

    echo "✓ $input"
}

export -f convert_task

find . -maxdepth 1 -type f \( \
    -iname "*.mp4" -o \
    -iname "*.mkv" -o \
    -iname "*.avi" -o \
    -iname "*.webm" -o \
    -iname "*.mov" -o \
    -iname "*.flv" \) \
    ! -name "*_x265.*" | \
    parallel -j 4 convert_task

