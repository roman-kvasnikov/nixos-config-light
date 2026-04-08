{
  config,
  pkgs,
  ...
}: let
  remnawave-sync = pkgs.writeShellScriptBin "remnawave-sync" (
    builtins.readFile ./remnawave-sync.sh
  );
in {
  config = lib.mkIf config.services.xray.enable {
    home.packages = [
      remnawave-sync
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];

    services.xray = {
      settingsFile = config.home.homeDirectory + "/.config/xray/config.json";
    };
  };

  systemd.user.services.xray = {
    Unit = {
      Description = "User Xray Service";

      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
      Requires = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";

      ExecStart = "${pkgs.xray}/bin/xray run -c ${config.services.xray.settingsFile}";
      ExecStop = "${pkgs.xray}/bin/xray stop";

      Restart = "always";
      RestartSec = 5;

      StandardOutput = "append:${config.home.homeDirectory}/.config/xray/xray.log";
      StandardError = "append:${config.home.homeDirectory}/.config/xray/xray.log";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
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

      StandardOutput = "append:${config.home.homeDirectory}/.config/xray/remnawave-sync.log";
      StandardError = "append:${config.home.homeDirectory}/.config/xray/remnawave-sync.log";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
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
}
