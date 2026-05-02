{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.homevpn-auto;

  homevpn-auto = pkgs.callPackage ./package/homevpn-auto.nix {
    inherit pkgs;
    inherit (cfg) homeSsid homeGatewayIp homeGatewayMac manualOverrideMinutes handshakeMaxAgeSeconds interfaceName timerInterval;
    inherit config;
  };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [homevpn-auto];

    systemd.user.services.homevpn-auto = {
      Unit = {
        Description = "Home VPN automatic management";
        After = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${homevpn-auto}/bin/homevpn-auto";
      };
    };

    systemd.user.timers.homevpn-auto = {
      Unit = {
        Description = "Home VPN automatic management timer";
      };
      Timer = {
        OnBootSec = "30s";
        OnUnitActiveSec = cfg.timerInterval;
        Unit = "homevpn-auto.service";
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
