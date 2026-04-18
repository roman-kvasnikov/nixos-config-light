{hostname, ...}: {
  networking = {
    hostName = hostname;

    proxy.default = "socks://127.0.0.1:10808";
    proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";
    # proxy.default = "socks://192.168.1.3:10808";
    # proxy.noProxy = "localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12";

    networkmanager = {
      enable = true;

      wifi.powersave = false;
      ethernet.macAddress = "preserve";
    };
  };
}
