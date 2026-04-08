{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.hyprland-display-switcher;
  hyprland-display-switcher = pkgs.callPackage ./package/package.nix {inherit cfg pkgs;};
in {
  config = lib.mkIf cfg.enable {
    systemd.user.paths.hyprland-display-switcher = {
      Unit = {
        Description = "Monitor for display changes";

        After = ["hyprland-session.target"];
        PartOf = ["hyprland-session.target"];
        Requires = ["hyprland-session.target"];
      };

      Path = {
        PathModified = "/sys/class/drm";
        MakeDirectory = false;
        DirectoryNotEmpty = "/sys/class/drm";
      };

      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };

    systemd.user.services.hyprland-display-switcher = {
      Unit = {
        Description = "Hyprland Display Switcher";

        After = ["hyprland-session.target"];
        PartOf = ["hyprland-session.target"];
        Requires = ["hyprland-session.target"];
      };

      Service = {
        Type = "oneshot";

        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.hyprland
          ]}"
        ];

        ExecStart = "${hyprland-display-switcher}/bin/hyprland-display-switcher";
      };

      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
