{pkgs, ...}: let
  builtinMonitor = "eDP-1, 3120x2080@90.00, auto, 1.6";
  externalMonitor = "DP-3, 2560x1440@165.00, auto, 1";
  fallbackMonitor = ", preferred, auto, 1";
in {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "hyprland-display-switcher" ''
      #!/usr/bin/env bash

      set -euo pipefail

      # Основные пути
      readonly BUILTIN_MONITOR="${builtinMonitor}" # Встроенный монитор ноутбука

      # Цвета для вывода (ANSI escape codes)
      readonly RED='\033[0;31m'
      readonly GREEN='\033[0;32m'
      readonly YELLOW='\033[1;33m'
      readonly BLUE='\033[0;34m'
      readonly PURPLE='\033[0;35m'
      readonly CYAN='\033[0;36m'
      readonly WHITE='\033[1;37m'
      readonly NC='\033[0m' # No Color

      # Утилиты для вывода
      print_success() {
        printf "%b %s\n" "''${GREEN}[✓]''${NC}" "$1"
      }

      print_info() {
        printf "%b %s\n" "''${BLUE}[i]''${NC}" "$1"
      }

      print_warning() {
        printf "%b %s\n" "''${YELLOW}[!]''${NC}" "$1"
      }

      print_error() {
        printf "%b %s\n" "''${RED}[✗]''${NC}" "$1" >&2
      }

      print_header() {
        printf "%b%s%b\n" "''${PURPLE}" "$1" "''${NC}"
      }

      print_status() {
        printf "%b%s%b\n" "''${CYAN}" "$1" "''${NC}"
      }

      # Функция для подсчета подключенных мониторов
      count_monitors() {
        hyprctl monitors all 2>/dev/null | grep -c "^Monitor" || true
      }

      # Функция для извлечения имени монитора
      monitor_name() {
        echo "$1" | cut -d',' -f1
      }

      # sleep 0.5

      print_info "Checking monitor configuration..."

      MONITORS=$(count_monitors)
      print_info "Total connected monitors: $MONITORS"

      if [ "$MONITORS" -gt 1 ]; then
        # Если есть внешние мониторы - всегда отключаем встроенный
        print_info "External monitor detected, ensuring built-in is disabled"
        hyprctl keyword monitor "$(monitor_name "$BUILTIN_MONITOR"), disable"
        print_success "Built-in monitor disabled"
      else
        # Если только встроенный - всегда включаем
        print_info "Only built-in monitor detected, ensuring it's enabled"
        hyprctl keyword monitor "$BUILTIN_MONITOR"
        print_success "Built-in monitor enabled"
      fi
    '')
  ];

  systemd.user.paths.hyprland-display-switcher = {
    Unit = {
      Description = "Monitor for display changes";

      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
      Requires = ["hyprland-session.target"];
    };

    Path = {
      PathModified = "/sys/class/drm";
      MakeDirectory = false;
      DirectoryNotEmpty = "/sys/class/drm";
    };

    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };

  systemd.user.services.hyprland-display-switcher = {
    Unit = {
      Description = "Hyprland Display Switcher";

      After = ["hyprland-session.target"];
      PartOf = ["hyprland-session.target"];
      Requires = ["hyprland-session.target"];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher";

      Environment = [
        "PATH=${lib.makeBinPath [
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.hyprland
        ]}"
      ];
    };

    Install = {
      WantedBy = ["hyprland-session.target"];
    };
  };
}
