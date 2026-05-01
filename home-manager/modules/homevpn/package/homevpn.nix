{
  pkgs,
  configFile,
  interfaceName,
  overrideFile,
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
      "@configFile@"
      "@interfaceName@"
      "@overrideFile@"
    ]
    [
      configFile
      interfaceName
      overrideFile
    ]
    (builtins.readFile ./homevpn.sh);
}
