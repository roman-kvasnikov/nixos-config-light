{lib, ...}: {
  options.modules.homevpn-auto = {
    enable = lib.mkEnableOption "Automatic VPN management based on network location";

    homeGatewayIps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "IP addresses of home gateways (one per home VLAN)";
      example = ["192.168.10.1" "192.168.30.1"];
    };

    homeGatewayMac = lib.mkOption {
      type = lib.types.str;
      description = "MAC address of home gateways (lowercase, colon-separated)";
      example = "aa:bb:cc:dd:ee:ff";
    };

    manualOverrideMinutes = lib.mkOption {
      type = lib.types.int;
      default = 180;
      description = "How long manual VPN actions are respected before automation resumes";
    };

    handshakeMaxAgeSeconds = lib.mkOption {
      type = lib.types.int;
      default = 180;
      description = "Maximum age of WireGuard handshake before considering tunnel broken";
    };

    interfaceName = lib.mkOption {
      type = lib.types.str;
      default = "homevpn";
      description = "Name of the VPN tunnel network interface";
    };

    timerInterval = lib.mkOption {
      type = lib.types.str;
      default = "3min";
      description = "How often the safety-net timer runs (systemd time format)";
    };
  };
}
