{pkgs, ...}:
pkgs.writeShellScriptBin "remnawave-sync"
(
  builtins.readFile ./remnawave-sync.sh
)
