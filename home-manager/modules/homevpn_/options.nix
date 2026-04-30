{
  lib,
  config,
  ...
}: {
  options.services.homevpn = {
    enable = lib.mkEnableOption "Home VPN L2TP/IPsec management tool";

    configFile = lib.mkOption {
      description = "Path to configuration file";
      type = lib.types.path;
      default = "${config.xdg.configHome}/homevpn/config.json";
    };
  };
}
