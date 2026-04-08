#!/usr/bin/env bash

# Строгий режим для bash
set -euo pipefail
IFS=$'\n\t'

# =============================================================================
# КОНСТАНТЫ И КОНФИГУРАЦИЯ
# =============================================================================

# Основные пути
readonly BUILTIN_MONITOR="@builtinMonitor@" # Встроенный монитор ноутбука

# Цвета для вывода (ANSI escape codes)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# УТИЛИТЫ ДЛЯ ВЫВОДА
# =============================================================================

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

info() {
    echo -e "${BLUE}[i]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

header() {
    echo -e "${PURPLE}$1${NC}"
}

status() {
    echo -e "${CYAN}$1${NC}"
}

# =============================================================================
# ВАЛИДАЦИЯ И ПРОВЕРКИ
# =============================================================================

# Проверить, что скрипт запущен не от root
check_user() {
    if [ "$(id -u)" -eq 0 ]; then
        error "This script should not be run as root"
        exit 1
    fi
}

# Проверить наличие необходимых зависимостей
check_dependencies() {
    local missing_deps=()

    if ! command -v hyprctl >/dev/null 2>&1; then
        missing_deps+=("hyprctl")
    fi

    if ! command -v grep >/dev/null 2>&1; then
        missing_deps+=("grep")
    fi

    if ! command -v cut >/dev/null 2>&1; then
        missing_deps+=("cut")
    fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        error "Make sure hyprctl, grep, cut are installed"
        exit 1
    fi
}

# =============================================================================
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# =============================================================================

# Функция для подсчета подключенных мониторов
count_monitors() {
	hyprctl monitors all | grep -c "^Monitor"
}

# Функция для извлечения имени монитора
monitor_name() {
	echo "$1" | cut -d',' -f1
}

# =============================================================================
# ОСНОВНАЯ ЛОГИКА
# =============================================================================

main() {
	info "Checking monitor configuration..."

	local total_monitors=$(count_monitors)
	info "Total connected monitors: $total_monitors"

	if [ "$total_monitors" -gt 1 ]; then
		# Если есть внешние мониторы - всегда отключаем встроенный
		info "External monitor detected, ensuring built-in is disabled"
		hyprctl keyword monitor "$(monitor_name "$BUILTIN_MONITOR"), disable"
		success "Built-in monitor disabled"
	else
		# Если только встроенный - всегда включаем
		info "Only built-in monitor detected, ensuring it's enabled"
		hyprctl keyword monitor "$BUILTIN_MONITOR"
		success "Built-in monitor enabled"
	fi
}

# =============================================================================
# ТОЧКА ВХОДА
# =============================================================================

# Проверки при запуске
check_user
check_dependencies

sleep 1

# Запуск основной логики
main "$@"
