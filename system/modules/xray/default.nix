{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.xray;
in {
  options.services.xrayctl = {
    enable = mkEnableOption "Xray proxy service";

    package = mkOption {
      type = types.package;
      default = pkgs.xray;
      description = "Xray package to use.";
    };

    configFile = mkOption {
      type = types.path;
      example = "/etc/xray/config.json";
      description = "Path to Xray config.json";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.xray = {
      description = "Xray Service";
      documentation = ["https://xtls.github.io/"];

      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target"];

      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";

        ExecStart = "${cfg.package}/bin/xray run -config ${cfg.configFile}";

        # Динамический пользователь
        DynamicUser = true;
        User = "xray";
        Group = "xray";

        # Restart policy
        Restart = "on-failure";
        RestartSec = "5s";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
