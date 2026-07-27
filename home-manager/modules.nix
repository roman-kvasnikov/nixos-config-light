{config, ...}: {
  modules = {
    homevpn = {
      enable = true;

      # configPath = "${config.xdg.configHome}/homevpn/homevpn.conf";
      # interfaceName = "homevpn";
    };

    homevpn-auto = {
      enable = true;

      homeGatewayIps = ["192.168.10.1" "192.168.30.1"];
      homeGatewayMac = "bc:24:11:95:c6:82";
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
