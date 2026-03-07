{hostname, ...}: {
  networking = {
    hostName = hostname;

    networkmanager = {
      enable = true;

      wifi.powersave = false;
      ethernet.macAddress = "preserve";
    };
  };
}
