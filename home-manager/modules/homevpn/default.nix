{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.homevpn;
  homevpn = pkgs.callPackage ./package/homevpn.nix {inherit pkgs cfg;};
in {
  imports = [
    ./options.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      homevpn
      pkgs.amneziawg-tools
    ];
  };
}
