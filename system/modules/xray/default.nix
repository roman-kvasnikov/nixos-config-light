{pkgs, ...}: let
  remnawave-sync = pkgs.writeShellScriptBin "remnawave-sync" (
    builtins.readFile ./remnawave-sync.sh
  );
in {
  services.xray = {
    enable = false;

    settingsFile = "/etc/xray/config.json";
  };

  environment.systemPackages = with pkgs; [
    jq
    curl
    remnawave-sync
  ];

  systemd = {
    services = {
      remnawave-sync = {
        description = "Sync Xray config from Remnawave";
        path = with pkgs; [curl jq coreutils];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${remnawave-sync}/bin/remnawave-sync";
          StandardOutput = "append:/var/log/remnawave-sync.log";
          StandardError = "append:/var/log/remnawave-sync.log";
        };
      };

      xray.environment = {
        XRAY_LOCATION_ASSET = "/var/lib/xray";
      };
    };

    timers.remnawave-sync = {
      description = "Daily Remnawave config sync";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
        Persistent = true;
      };
    };
  };

  networking = {
    # proxy.default = "socks://127.0.0.1:10808";
    # proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
    proxy.default = "socks://192.168.1.3:10808";
    proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
  };
}
