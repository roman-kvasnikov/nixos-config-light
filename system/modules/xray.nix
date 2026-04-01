{
  services.xray = {
    enable = true;

    settingsFile = "/etc/xray/config.json";
  };

  systemd.services.xray.environment = {
    XRAY_LOCATION_ASSET = "/var/lib/xray";
  };

  networking = {
    proxy.default = "socks://127.0.0.1:10808";
    proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
  };
}