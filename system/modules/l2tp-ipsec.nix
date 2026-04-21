{pkgs, ...}: {
  nixpkgs.overlays = [
    (self: super: {
      networkmanager-l2tp = super.networkmanager-l2tp.override {
        strongswan = self.libreswan;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    networkmanager-l2tp # GUI и интеграция
    xl2tpd # L2TP протокол
    libreswan # IPsec шифрование (если есть PSK)
    iproute2 # Нужен для libreswan
  ];

  networking = {
    networkmanager = {
      plugins = with pkgs; [
        networkmanager-l2tp
      ];
    };

    firewall = {
      allowedUDPPorts = [
        500 # IKE
        4500 # IPsec NAT-T
        1701 # L2TP
      ];
    };
  };

  services = {
    xl2tpd.enable = false;

    libreswan = {
      enable = true;

      configSetup = ''
        ikev1-policy=accept
        protostack=netkey
        plutodebug=none
        logfile=/var/log/pluto.log
        dumpdir=/run/pluto
        virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
      '';
    };
  };
}
