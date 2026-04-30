{config, ...}: {
  modules = {
    homevpn = {
      enable = true;

      # configPath = "${config.xdg.configHome}/homevpn/homevpn.conf";
      # interfaceName = "homevpn";
    };
  };

  services = {
    hyprland-display-switcher = {
      enable = true;

      # builtinMonitor = "eDP-1, 3120x2080@90.00, auto, 1.6";
      # externalMonitor = "DP-3, 2560x1440@165.00, auto, 1";
      # fallbackMonitor = ", preferred, auto, 1";
    };

    xray = {
      enable = true;

      # workingDirectory = "${config.xdg.configHome}/xray";
      # configFile = "${config.xdg.configHome}/xray/config.json";
    };
  };
}
