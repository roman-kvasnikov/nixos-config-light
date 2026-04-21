{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.xray;
  remnawave-sync = pkgs.callPackage ./package/remnawave-sync.nix {inherit pkgs cfg;};
in {
  imports = [
    ./options.nix
    ./service.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      remnawave-sync
    ];
  };
}
