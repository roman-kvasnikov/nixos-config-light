{
  lib,
  config,
  ...
}: let
  homevpnctlConfig = config.services.homevpnctl;
in {
  config = lib.mkIf homevpnctlConfig.enable {
    xdg.configFile."homevpn/config.example.json".source = ./config.example.json;
  };
}
