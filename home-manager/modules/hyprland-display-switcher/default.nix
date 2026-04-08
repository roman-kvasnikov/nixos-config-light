{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.hyprland-display-switcher;
  hyprland-display-switcher = pkgs.callPackage ./package/package.nix {inherit cfg pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      hyprland-display-switcher
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.hyprland
    ];
  };
}
