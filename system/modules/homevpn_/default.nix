{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.homevpnctl;
in {
  options.services.homevpnctl = {
    enable = mkEnableOption "Home VPN L2TP/IPsec Connection Daemon";

    configFile = mkOption {
      type = types.path;
      default = "/etc/homevpn/config.json";
      description = "Path to Home VPN L2TP/IPsec config.json";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.homevpn = {
      description = "Home VPN L2TP/IPsec Connection Daemon";

      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target"];

      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";

        ExecStart = "/usr/local/bin/homevpnctl daemon";
        ExecStop = "/usr/local/bin/homevpnctl clean";
        ExecStart = "${cfg.package}/bin/xray run -config ${cfg.configFile}";
        ExecStart = "${homevpnctl}/bin/homevpnctl daemon";

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
