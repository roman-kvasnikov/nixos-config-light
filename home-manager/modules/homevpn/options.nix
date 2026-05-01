{
  lib,
  config,
  ...
}: {
  options.modules.homevpn = {
    enable = lib.mkEnableOption "Home VPN (AmneziaWG) CLI wrapper over awg-quick";

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/homevpn/homevpn.conf";
      description = "Path to the AmneziaWG client config file";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "homevpn";
      description = "Name of the VPN tunnel network interface";
    };

    overrideFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.cacheHome}/homevpn/manual-override";
      description = "Path to the manual override file";
    };
  };
}
