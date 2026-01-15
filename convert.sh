#!/bin/bash

# Создаем папку для результатов
rm -rf converted_av1
mkdir -p converted_av1

echo "=== Начало конвертации в AV1 ==="
echo "================================"

# Конвертируем все .mkv и .mp4 файлы
for file in *.{mkv,mp4,MOV,mov}; do
    if [ -f "$file" ]; then
        echo "Конвертирую: $file"
        filename=$(basename "$file" | cut -d. -f1)

        ffmpeg -i "$file" \
            -c:v libsvtav1 \
            -crf 20 \
            -preset 2 \
            -pix_fmt yuv420p \
            -g 240 \
            -svtav1-params "film-grain=8:film-grain-denoise=0:aq-mode=1:enable-qm=1:qm-min=8:qm-max=10" \
            -an -sn \
            "converted_av1/${filename}_av1.mp4"

        echo "Готово: ${filename}_av1.mp4"
    fi
done

echo "========================================"
echo "Конвертация завершена!"
echo "Файлы сохранены в папку: converted_av1/"
