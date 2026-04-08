{
  cfg,
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
    cfg.builtinMonitor
  ]
  (builtins.readFile ./source.sh)
)
