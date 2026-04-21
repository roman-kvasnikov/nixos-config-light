{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.homevpnctl;
  homevpnctl = pkgs.callPackage ./package/package.nix {inherit cfg pkgs;};
in {
  config = lib.mkIf cfg.enable {
    systemd.user.services.homevpnctl = {
      Unit = {
        Description = "Home VPN L2TP/IPsec Connection Daemon";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };

      Service = {
        Type = "simple";

        ExecStart = "${homevpnctl}/bin/homevpnctl daemon";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        # Restart политика
        Restart = "on-failure";
        RestartSec = "30s";

        # Процессы и сигналы
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        TimeoutStopSec = "30s";

        # Окружение
        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.coreutils
            pkgs.jq
            pkgs.networkmanager
            pkgs.iproute2
            pkgs.iputils
            pkgs.net-tools
            pkgs.systemd
            pkgs.gnugrep
            pkgs.gawk
            pkgs.gnused
          ]}"
        ];

        # Логирование
        StandardOutput = "journal";
        StandardError = "journal";

        # Безопасность
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [
          "${config.xdg.configHome}/homevpn"
        ];

        # Network
        PrivateNetwork = false;

        # Capabilities
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
