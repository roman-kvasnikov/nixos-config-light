{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.xray;
  remnawave-sync = pkgs.callPackage ./package/remnawave-sync.nix {inherit cfg pkgs;};
in {
  imports = [
    ./options.nix
    ./service.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = [
      remnawave-sync
      pkgs.xray
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];
  };
}
