#!/bin/bash

echo "=== Начало конвертации в x265 ==="
echo "================================="

# Ищем видеофайлы (рекурсивно или только в текущей?)
find . -type f \( \
    -iname "*.mp4" -o \
    -iname "*.mov" -o \
    -iname "*.avi" -o \
    -iname "*.mkv" -o \
    -iname "*.wmv" -o \
    -iname "*.webm" -o \
    -iname "*.m4v" -o \
    -iname "*.3gp" -o \
    -iname "*.mts" -o \
    -iname "*.m2ts" -o \
    -iname "*.ts" -o \
    -iname "*.flv" \) \
    ! -path "./converted/*" > all_files.txt

echo "Найдено файлов: $(wc -l < all_files.txt)"

# Генерируем команды
> commands.txt
> skipped.txt
> errors.txt
> conversion.txt

while read input_file; do
  # Убираем начальную ./ если есть
  input_file="${input_file#./}"

  # Проверка доступности файла
  if [ ! -r "$input_file" ]; then
    echo "Ошибка доступа: $input_file" >> errors.txt
    continue
  fi

  # Определяем расширение файла
  extension="${input_file##*.}"
  filename_no_ext="${input_file%.*}"

  # Создаем имя выходного файла
  output_file="${filename_no_ext}.mp4"

  mkdir -p converted 2>/dev/null
  output_file="converted/${output_file}"
  mkdir -p "$(dirname "$output_file")" 2>/dev/null

  # Пропуск существующих файлов
  if [ -f "$output_file" ]; then
    echo "Пропускаем '$input_file' - уже существует в папке converted" >> skipped.txt
    continue
  fi

  codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$input_file" 2>/dev/null)
  if [[ "$codec" == "hevc" ]]; then
    echo "Пропускаем '$input_file' - уже в формате HEVC/x265" >> skipped.txt
    continue
  fi

  echo "ffmpeg -i \"$input_file\" -c:v libx265 -preset medium -crf 23 -c:a aac -b:a 192k -y -hide_banner -loglevel error \"$output_file\"" >> commands.txt
done < all_files.txt

echo "Пропущенных файлов: $(wc -l < skipped.txt)"
echo "Сгенерировано команд: $(wc -l < commands.txt)"

# Запуск с логированием ошибок
if [ -s commands.txt ]; then
  echo "Запуск конвертации..."
  parallel -j 4 --load 80% --joblog conversion.txt --progress < commands.txt
fi

echo "========================================"
echo "Конвертация завершена!"
echo "Файлы сохранены в папку: converted"
echo "Логи ошибок: errors.txt"
echo "Лог пропущенных файлов: skipped.txt"
echo "Лог заданий: conversion.txt"
