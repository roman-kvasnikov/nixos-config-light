{
  lib,
  config,
  ...
}: {
  options.services.xray = {
    enable = lib.mkEnableOption "Xray";

    workingDirectory = lib.mkOption {
      description = "Xray working directory";
      type = lib.types.str;
      default = "${config.xdg.configHome}/xray";
    };

    configFile = lib.mkOption {
      description = "Xray config file";
      type = lib.types.str;
      default = "${config.xdg.configHome}/xray/config.json";
    };
  };
}
