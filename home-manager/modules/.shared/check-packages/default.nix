{pkgs, ...}: (pkgs.writeShellScriptBin "check-packages" (builtins.readFile ./source.sh))
