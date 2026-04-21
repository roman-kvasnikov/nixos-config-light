{
  homevpnctlConfig,
  config,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "homevpnctl"
(
  builtins.replaceStrings
  [
    "@configDirectory@"
    "@configFile@"
  ]
  [
    "${config.xdg.configHome}/homevpn"
    homevpnctlConfig.configFile
  ]
  (builtins.readFile ./source.sh)
)
