{
  pkgs,
  cfg,
  ...
}:
pkgs.writeShellApplication {
  name = "homevpn";

  runtimeInputs = with pkgs; [
    amneziawg-tools
    iproute2
    sudo
  ];

  text =
    builtins.replaceStrings
    [
      "@configPath@"
      "@interfaceName@"
    ]
    [
      cfg.configPath
      cfg.interfaceName
    ]
    (builtins.readFile ./homevpn.sh);
}
