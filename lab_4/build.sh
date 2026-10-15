#!/bin/bash

# Проверка, что передан аргумент
if [ -z "$1" ]; then
    echo "Использование: $0 <файл.asm>"
    exit 1
fi

# Убираем расширение .asm, если оно есть
FILE="${1%.asm}"

# Сборка FASM
fasm "$FILE.asm" || { echo "Ошибка FASM"; exit 1; }

# Линковка
ld "$FILE.o" -o a.out || { echo "Ошибка LD"; exit 1; }

# Запуск
./a.out
