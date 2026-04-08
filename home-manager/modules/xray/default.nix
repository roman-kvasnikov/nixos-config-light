{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.xrayctl;
  remnawave-sync = pkgs.writeShellScriptBin "remnawave-sync" (
    builtins.readFile ./remnawave-sync.sh
  );
in {
  config = lib.mkIf cfg.enable {
    home.packages = [
      remnawave-sync
      pkgs.xray
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];

    systemd.user.services.xray = {
      Unit = {
        Description = "User Xray Service";
        Documentation = "https://xtls.github.io/";

        After = ["network-online.target" "nss-lookup.target"];
        Wants = ["network-online.target" "nss-lookup.target"];
      };

      Service = {
        Type = "simple";

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
          "${config.xdg.configHome}/xray"
        ];
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.services.remnawave-sync = {
      Unit = {
        Description = "Sync Xray config from Remnawave Panel";

        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        Requires = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";

        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.coreutils
            pkgs.curl
            pkgs.jq
          ]}"
        ];

        ExecStart = "${remnawave-sync}/bin/remnawave-sync";

        StandardOutput = "journal";
        StandardError = "journal";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.timers.remnawave-sync = {
      Unit = {
        Description = "Daily Remnawave Panel config sync";
      };

      Timer = {
        OnCalendar = "*-*-* 05:00:00";
        Persistent = true;
      };

      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
