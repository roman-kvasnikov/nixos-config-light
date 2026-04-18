{
  inputs,
  pkgs,
  ...
}: {
  # ------------------------------------------------------------
  # DESKTOP / WAYLAND / HYPRLAND / CAELESTIA
  # Графическая оболочка и её инструменты
  # ------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Caelestia
    inputs.quickshell.packages.${pkgs.system}.default
    inputs.caelestia-shell.packages.${pkgs.system}.default
    inputs.caelestia-cli.packages.${pkgs.system}.default

    # Wayland terminal
    foot

    # File managers
    # thunar
    nautilus

    # Screenshots
    swappy

    # Audio system
    wireplumber
    aubio
    libcava

    # System helpers
    brightnessctl
    app2unit

    # Themes / UI
    adw-gtk3
    papirus-icon-theme
    material-symbols

    # Qt integration
    qt5.qtwayland
    qt6.qtwayland

    # Hyprland ecosystem (optional)
    # hyprpaper
    hyprpicker
    # hyprlauncher
    # hypridle
    # hyprlock
    # hyprsysteminfo
    hyprpolkitagent
    # hyprpwcenter
    # hyprshutdown
    # hyprcursor
    # hyprshot

    # Wayland utilities
    wl-clipboard
    cliphist

    # Bars / launchers / notifications (optional)
    # waybar
    # wofi
    # mako
    # wlogout
  ];
}
