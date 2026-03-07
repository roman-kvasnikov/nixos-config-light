{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      # Hyprland specific
      hyprpaper # Wallpaper manager
      hyprpicker # Color picker
      hyprlauncher #  App launcher
      hypridle # Idle detection
      hyprlock # Screen locker
      hyprsysteminfo # System info
      hyprpolkitagent # Polkit agent
      hyprpwcenter
      hyprshutdown
      hyprcursor
      hyprshot # Screenshot tool

      # Hyprland utilities
      waybar # Status bar
      wofi # Application launcher
      mako # Notification daemon
      wlogout # Logout menu

      # System utilities
      libnotify # Notification daemon
      pamixer # Volume control
      brightnessctl # Brightness control
    ];
  };
}
