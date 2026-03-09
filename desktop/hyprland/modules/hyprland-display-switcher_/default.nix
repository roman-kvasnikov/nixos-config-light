{
  pkgs,
  lib,
  ...
}: let
  builtinMonitor = "eDP-1, 3120x2080@90.00, auto, 1.6";
  externalMonitor = "DP-3, 2560x1440@165.00, auto, 1";
  fallbackMonitor = ", preferred, auto, 1";

  hyprlandDisplaySwitcher = pkgs.writeShellScriptBin "hyprland-display-switcher" ''
    #!/usr/bin/env bash
    set -euo pipefail

    # Цвета ANSI
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly PURPLE='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly WHITE='\033[1;37m'
    readonly NC='\033[0m'

    # Лог-функции
    print_success() { printf "%b %s\n" "$GREEN[✓]$NC" "$1"; }
    print_info()    { printf "%b %s\n" "$BLUE[i]$NC" "$1"; }
    print_warning() { printf "%b %s\n" "$YELLOW[!]$NC" "$1"; }
    print_error()   { printf "%b %s\n" "$RED[✗]$NC" "$1" >&2; }
    print_header()  { printf "%b%s%b\n" "$PURPLE" "$1" "$NC"; }
    print_status()  { printf "%b%s%b\n" "$CYAN" "$1" "$NC"; }

    # Проверка hyprctl
    command -v hyprctl >/dev/null || { print_error "hyprctl not found"; exit 1; }

    # Подсчёт мониторов
    count_monitors() {
      hyprctl monitors all 2>/dev/null | grep -c "^Monitor" || true
    }

    # Имя монитора
    monitor_name() {
      echo "$1" | cut -d',' -f1
    }

    # Проверка конфигурации
    print_info "Checking monitor configuration..."
    MONITORS=$(count_monitors)
    print_info "Total connected monitors: $MONITORS"

    sleep 0.5  # безопасная задержка для обновления состояния

    if [ "$MONITORS" -gt 1 ]; then
      print_info "External monitor detected, disabling built-in"
      hyprctl keyword monitor "$(monitor_name "$builtinMonitor"), disable"
      print_success "Built-in monitor disabled"
    else
      print_info "Only built-in monitor detected, enabling it"
      hyprctl keyword monitor "$builtinMonitor"
      print_success "Built-in monitor enabled"
    fi
  '';
in {
  environment.systemPackages = [
    hyprlandDisplaySwitcher
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
