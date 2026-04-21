{
  lib,
  config,
  ...
}: {
  options.services.homevpnctl = {
    enable = lib.mkEnableOption "Home VPN L2TP/IPsec management tool";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/homevpn/config.json";
      description = "Path to configuration file";
    };
  };
}
