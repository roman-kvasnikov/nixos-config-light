let
  remnawave-sync-pc = pkgs.writeShellScriptBin "remnawave-sync-pc" (
    builtins.readFile ./remnawave-sync-pc.sh
  );
in
{
  services.xray = {
    enable = true;

    settingsFile = "/etc/xray/config.json";
  };

  environment.systemPackages = with pkgs; [
    jq
    curl
    remnawave-sync-pc
  ];

  systemd = {
    services = {
      remnawave-sync-pc = {
        description = "Sync Xray config from Remnawave";
        path = with pkgs; [ curl jq coreutils ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${remnawave-sync-pc}/bin/remnawave-sync-pc";
          StandardOutput = "append:/var/log/remnawave-sync-pc.log";
          StandardError = "append:/var/log/remnawave-sync-pc.log";
        };
      };

      xray.environment = {
        XRAY_LOCATION_ASSET = "/var/lib/xray";
      };
    };

    timers.remnawave-sync-pc = {
      description = "Daily Remnawave config sync";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
        Persistent = true;
      };
    };
  };

  networking = {
    proxy.default = "socks://127.0.0.1:10808";
    proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
  };
}