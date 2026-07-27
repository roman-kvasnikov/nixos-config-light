{
  pkgs,
  lib,
  homeGatewayIps,
  homeGatewayMac,
  manualOverrideMinutes,
  handshakeMaxAgeSeconds,
  interfaceName,
  timerInterval,
  config,
  ...
}:
pkgs.writeShellApplication {
  name = "homevpn-auto";

  runtimeInputs = with pkgs; [
    amneziawg-tools
    networkmanager
    iproute2
    util-linux
    coreutils
    gawk
    gnugrep
    inetutils
  ];

  text =
    builtins.replaceStrings
    [
      "@homeGatewayIps@"
      "@homeGatewayMac@"
      "@overrideTimeoutSeconds@"
      "@handshakeMaxAgeSeconds@"
      "@interfaceName@"
      "@overrideFile@"
    ]
    [
      (pkgs.lib.concatStringsSep " " homeGatewayIps)
      homeGatewayMac
      (toString (manualOverrideMinutes * 60))
      (toString handshakeMaxAgeSeconds)
      interfaceName
      config.modules.homevpn.overrideFile
    ]
    (builtins.readFile ./homevpn-auto.sh);
}
