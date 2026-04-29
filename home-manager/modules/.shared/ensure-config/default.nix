{pkgs, ...}: (pkgs.writeShellScriptBin "ensure-config" (builtins.readFile ./source.sh))
