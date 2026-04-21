{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.homevpnctl;
  homevpnctl = pkgs.callPackage ./package/package.nix {inherit cfg pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      homevpnctl
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
