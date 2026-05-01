{
  pkgs,
  configPath,
  interfaceName,
  ...
}:
pkgs.writeShellApplication {
  name = "homevpn";

  runtimeInputs = with pkgs; [
    amneziawg-tools
    iproute2
  ];

  text =
    builtins.replaceStrings
    [
      "@configPath@"
      "@interfaceName@"
    ]
    [
      configPath
      interfaceName
    ]
    (builtins.readFile ./homevpn.sh);
}
