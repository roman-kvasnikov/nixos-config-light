{
  lib,
  config,
  ...
}: {
  options.services.xray = {
    enable = lib.mkEnableOption "Xray";

    configFile = lib.mkOption {
      description = "Xray config file";
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.config/xray/config.json";
    };
  };
}
