{
  lib,
  config,
  ...
}: let
  cfg = config.services.homevpn;
in {
  config = lib.mkIf cfg.enable {
    xdg.configFile."homevpn/config.example.json".source = ./config.example.json;
  };
}
