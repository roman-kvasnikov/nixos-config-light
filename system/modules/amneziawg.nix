{
  config,
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs; [
    amneziawg-tools
    amneziawg-go
  ];

  # awg-quick без kernel-модуля уходит в userspace и зовёт amneziawg-go.
  # sudo сбрасывает PATH, поэтому прокидываем его в саму обёртку awg-quick.
  nixpkgs.overlays = [
    (final: prev: {
      amneziawg-tools = prev.amneziawg-tools.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.makeWrapper];
        postFixup =
          (old.postFixup or "")
          + ''
            wrapProgram $out/bin/awg-quick \
              --prefix PATH : ${final.amneziawg-go}/bin
          '';
      });
    })
  ];

  # boot = {
  #   extraModulePackages = with config.boot.kernelPackages; [
  #     amneziawg
  #   ];

  #   kernelModules = ["amneziawg"];
  # };

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
