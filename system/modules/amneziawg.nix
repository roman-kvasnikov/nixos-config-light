{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    amneziawg-tools
  ];

  boot = {
    kernelModules = ["amneziawg"];
    extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];
  };
}
