{
  pkgs,
  workingDirectory,
  configFile,
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
      workingDirectory
      configFile
    ]
    (builtins.readFile ./remnawave-sync.sh);
}
