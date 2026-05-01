{
  pkgs,
  homeSsid,
  homeGatewayIp,
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
    networkmanager
    iproute2
    amneziawg-tools
    util-linux
    coreutils
    gawk
    gnugrep
    inetutils
  ];

  text =
    builtins.replaceStrings
    [
      "@homeSsid@"
      "@homeGatewayIp@"
      "@homeGatewayMac@"
      "@overrideTimeoutSeconds@"
      "@handshakeMaxAgeSeconds@"
      "@interfaceName@"
      "@overrideFile@"
    ]
    [
      homeSsid
      homeGatewayIp
      homeGatewayMac
      (toString (manualOverrideMinutes * 60))
      (toString handshakeMaxAgeSeconds)
      interfaceName
      config.modules.homevpn.overrideFile
    ]
    (builtins.readFile ./homevpn-auto.sh);
}
