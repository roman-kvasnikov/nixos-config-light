{
  lib,
  config,
  ...
}: {
  options.modules.homevpn = {
    enable = lib.mkEnableOption "Home VPN (AmneziaWG) CLI wrapper over awg-quick";

    configPath = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/homevpn/homevpn.conf";
      description = "Path to the AmneziaWG client config file";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "homevpn";
      description = "Name of the VPN tunnel network interface";
    };
  };
}
