{
  config,
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs; [
    amneziawg-tools
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];

    kernelModules = ["amneziawg"];
  };

  security.sudo.extraRules = [
    {
      users = [user.name];
      commands = [
        {
          command = "${pkgs.amneziawg-tools}/bin/awg-quick";
          options = ["NOPASSWD"];
        }
        {
          command = "${pkgs.amneziawg-tools}/bin/awg";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
