{pkgs, ...}: (pkgs.writeShellScriptBin "check-user" (builtins.readFile ./source.sh))
