{
  pkgs,
  cfg,
  config,
  ...
}:
pkgs.writeShellScriptBin "homevpn"
(
  builtins.replaceStrings
  [
    "@configDirectory@"
    "@configFile@"
  ]
  [
    "${config.xdg.configHome}/homevpn"
    cfg.configFile
  ]
  (builtins.readFile ./homevpn.sh)
)
