#!/bin/bash

# Упрощенный скрипт для конвертирования в H.265 без аудио и субтитров

# Проверяем установлен ли ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "Ошибка: ffmpeg не установлен."
    exit 1
fi

echo "Конвертация всех видео в H.265 без аудио и субтитров..."
echo "====================================================="

# Обрабатываем все видео файлы
for file in *.{mp4,mov,avi,mkv,wmv,flv,webm,m4v,3gp,mts,m2ts,ts}; do
    if [ -f "$file" ] && [[ "$file" != *_h265.* ]]; then
        filename=$(basename -- "$file")
        filename_noext="${filename%.*}"
        output_file="${filename_noext}_h265.mp4"
        
        echo "Обработка: $filename"
        
        ffmpeg -i "$file" \
            -c:v libx265 \
            -preset slow \
            -crf 18 \
            -an \
            -sn \
            -movflags +faststart \
            -pix_fmt yuv420p \
            "$output_file"
        
        if [ $? -eq 0 ]; then
            echo "✓ Успешно: $output_file"
        else
            echo "✗ Ошибка: $filename"
        fi
        echo "---"
    fi
done

echo "Готово!"
