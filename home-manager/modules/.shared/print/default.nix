{pkgs, ...}: (pkgs.writeShellScriptBin "print" (builtins.readFile ./source.sh))
