{
  hyprlandDisplaySwitcherConfig,
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "hyprland-display-switcher"
(
  builtins.replaceStrings
  [
    "@builtinMonitor@"
  ]
  [
    hyprlandDisplaySwitcherConfig.builtinMonitor
  ]
  (builtins.readFile ./source.sh)
)
