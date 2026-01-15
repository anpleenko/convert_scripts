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
    -iname "*.flv" \) > all_files.txt

echo "Найдено файлов: $(wc -l < all_files.txt)"

# Генерируем команды
> commands.txt  # Очищаем файл, если он существует

while read input_file; do
  # Убираем начальную ./ если есть
  input_file="${input_file#./}"

  # Определяем расширение файла
  extension="${input_file##*.}"
  filename_no_ext="${input_file%.*}"

  # Создаем имя выходного файла
  output_file="${filename_no_ext}.mp4"

  # Если хотим в поддиректорию converted/
  mkdir -p converted 2>/dev/null
  output_file="converted/${output_file}"
  mkdir -p "$(dirname "$output_file")" 2>/dev/null

  echo "ffmpeg -i '$input_file' -c:v libx265 -preset medium -crf 23 -c:a copy -y -hide_banner -loglevel error '$output_file'" >> commands.txt
done < all_files.txt

echo "Сгенерировано команд: $(wc -l < commands.txt)"

parallel -j 4 --load 80% < commands.txt

echo "========================================"
echo "Конвертация завершена!"
echo "Файлы сохранены в папку: converted"
