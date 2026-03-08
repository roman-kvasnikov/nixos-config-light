{
  lib,
  config,
  pkgs,
  ...
}: let
  homevpnctlConfig = config.services.homevpnctl;
  homevpnctl = pkgs.callPackage ./package/package.nix {inherit homevpnctlConfig config pkgs;};
  shared = pkgs.callPackage ../.shared {};
in {
  config = lib.mkIf homevpnctlConfig.enable {
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
          "PATH=${lib.makeBinPath (
            shared.home.packages
            ++ [
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
            ]
          )}"
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

    xdg = {
      configFile."homevpn/README.md".source = ./README.md;
    };
  };
}
