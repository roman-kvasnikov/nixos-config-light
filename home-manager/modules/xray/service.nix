{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.xray;
  remnawave-sync = pkgs.callPackage ./package/remnawave-sync.nix {inherit pkgs cfg;};
in {
  config = lib.mkIf cfg.enable {
    systemd.user.services.xray = {
      Unit = {
        Description = "User Xray Service";
        Documentation = "https://xtls.github.io/";

        After = ["network-online.target" "nss-lookup.target"];
        Wants = ["network-online.target" "nss-lookup.target"];
      };

      Service = {
        Type = "simple";

        WorkingDirectory = cfg.workingDirectory;

        Environment = [
          "XRAY_LOCATION_ASSET=${cfg.workingDirectory}"
        ];

        # ExecStartPre = "${remnawave-sync}/bin/remnawave-sync";
        ExecStart = "${pkgs.xray}/bin/xray run -config ${cfg.configFile}";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";

        # Restart политика
        Restart = "on-failure";
        RestartSec = "30s";

        # Процессы и сигналы
        KillMode = "mixed";
        KillSignal = "SIGTERM";
        TimeoutStopSec = "30s";

        # Логирование
        StandardOutput = "journal";
        StandardError = "journal";

        # Безопасность
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [
          cfg.workingDirectory
        ];
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    # systemd.user.services.remnawave-sync = {
    #   Unit = {
    #     Description = "Sync Xray config from Remnawave Panel";

    #     After = ["network-online.target" "nss-lookup.target"];
    #     Wants = ["network-online.target" "nss-lookup.target"];
    #   };

    #   Service = {
    #     Type = "oneshot";

    #     Environment = [
    #       "PATH=${lib.makeBinPath [
    #         pkgs.coreutils
    #         pkgs.curl
    #         pkgs.jq
    #       ]}"
    #     ];

    #     ExecStart = "${remnawave-sync}/bin/remnawave-sync";

    #     StandardOutput = "journal";
    #     StandardError = "journal";
    #   };

    #   Install = {
    #     WantedBy = ["default.target"];
    #   };
    # };

    # systemd.user.timers.remnawave-sync = {
    #   Unit = {
    #     Description = "Sync Xray config from Remnawave Panel";
    #   };

    #   Timer = {
    #     OnCalendar = "*-*-* 05:00:00";
    #     Persistent = true;
    #   };

    #   Install = {
    #     WantedBy = ["timers.target"];
    #   };
    # };
  };
}
