{
  pkgs,
  builtinMonitor,
  externalMonitor,
  fallbackMonitor,
  ...
}:
pkgs.writeShellApplication {
  name = "hyprland-display-switcher";

  runtimeInputs = with pkgs; [
    coreutils
    gnugrep
    hyprland
  ];

  text =
    builtins.replaceStrings
    [
      "@builtinMonitor@"
      "@externalMonitor@"
      "@fallbackMonitor@"
    ]
    [
      builtinMonitor
      externalMonitor
      fallbackMonitor
    ]
    (builtins.readFile ./hyprland-display-switcher.sh);
}
