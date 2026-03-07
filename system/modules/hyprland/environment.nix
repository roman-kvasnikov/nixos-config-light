{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Hyprland specific
    # hyprpaper # Wallpaper manager
    # hyprpicker # Color picker
    # hyprlauncher #  App launcher
    # hypridle # Idle detection
    # hyprlock # Screen locker
    # hyprsysteminfo # System info
    # hyprpolkitagent # Polkit agent
    # hyprpwcenter
    # hyprshutdown
    # hyprcursor
    # hyprshot # Screenshot tool

    # Hyprland utilities
    # waybar # Status bar
    # wofi # Application launcher
    # mako # Notification daemon
    # wlogout # Logout menu

    # System utilities
    # libnotify # Notification daemon
    # pamixer # Volume control
    brightnessctl # Brightness control

    inputs.quickshell.packages.${system}.default
    inputs.caelestia-shell.packages.${system}.default
    inputs.caelestia-cli.packages.${system}.default

    # Additional for Caelestia
    wl-clipboard
    cliphist
    inotify-tools
    app2unit
    wireplumber
    trash-cli
    foot
    fish
    fastfetch
    starship
    btop
    jq
    eza

    adw-gtk3
    papirus-icon-theme
    libsForQt5.qt5ct
    kdePackages.qt6ct
    yazi
    thunar

    quickshell
    aubio
    libcava
    swappy
    libqalculate
    bash
    material-symbols
  ];
}
