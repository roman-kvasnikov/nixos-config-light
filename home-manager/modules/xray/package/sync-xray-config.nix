{
  pkgs,
  workingDirectory,
  configFile,
  ...
}:
pkgs.writeShellApplication {
  name = "sync-xray-config";

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
    (builtins.readFile ./sync-xray-config.sh);
}
