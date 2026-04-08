{config, ...}: {
  services = {
    hyprland-display-switcher = {
      enable = true;

      # builtinMonitor = "eDP-1, 3120x2080@90.00, auto, 1.6";
      # externalMonitor = "DP-3, 2560x1440@165.00, auto, 1";
      # fallbackMonitor = ", preferred, auto, 1";
    };

    xrayctl = {
      enable = true;

      configFile = "${config.home.homeDirectory}/.config/xray/config.json";
    };
  };
}
