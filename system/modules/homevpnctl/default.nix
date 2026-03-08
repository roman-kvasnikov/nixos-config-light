{
  lib,
  config,
  pkgs,
  ...
}: let
  homevpnctlConfig = config.services.homevpnctl;
  homevpnctl = pkgs.callPackage ./package/package.nix {inherit homevpnctlConfig config pkgs;};
  shared = pkgs.callPackage ../.shared {};
in {
  imports = [
    ./options.nix
    ./service.nix
    ./config
  ];

  config = lib.mkIf homevpnctlConfig.enable {
    home.packages =
      shared.home.packages
      ++ [
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
