{
  pkgs,
  cfg,
  ...
}:
pkgs.writeShellApplication {
  name = "remnawave-sync";

  runtimeInputs = with pkgs; [
    coreutils
    diffutils
    curl
    jq
    systemd
  ];

  text =
    builtins.replaceStrings
    [
      "@workingDirectory@"
      "@configFile@"
    ]
    [
      cfg.workingDirectory
      cfg.configFile
    ]
    (builtins.readFile ./remnawave-sync.sh);
}
