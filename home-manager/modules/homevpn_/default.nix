{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.homevpn;
  homevpn = pkgs.callPackage ./package/homevpn.nix {inherit pkgs cfg config;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      homevpn
      pkgs.coreutils
      pkgs.jq
      pkgs.networkmanager
      pkgs.iproute2
      pkgs.iputils
      pkgs.net-tools
      pkgs.systemd
      pkgs.gnugrep
      pkgs.gawk
      pkgs.gnused
    ];
  };
}
