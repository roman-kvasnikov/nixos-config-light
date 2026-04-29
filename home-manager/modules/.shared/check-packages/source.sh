#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# Массив для отсутствующих зависимостей
missing_packages=()

# Проверяем каждую зависимость
for package in "$@"; do
    if ! command -v "$package" >/dev/null 2>&1; then
        missing_packages+=("$package")
    fi
done

# Если есть отсутствующие зависимости
if [ ${#missing_packages[@]} -gt 0 ]; then
    print --error "Missing packages: ${missing_packages[*]}"
    exit 1
fi
