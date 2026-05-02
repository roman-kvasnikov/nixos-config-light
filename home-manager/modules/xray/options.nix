{
  lib,
  config,
  ...
}: {
  options.services.xray = {
    enable = lib.mkEnableOption "Xray service";

    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/xray";
      description = "Xray service working directory";
    };

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.configHome}/xray/config.json";
      description = "Xray config file";
    };
  };
}
