{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.hyprland-display-switcher;

  hyprland-display-switcher = pkgs.callPackage ./package/hyprland-display-switcher.nix {
    inherit pkgs;
    inherit (cfg) builtinMonitor externalMonitor fallbackMonitor;
  };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [hyprland-display-switcher];

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

        ExecStart = "${hyprland-display-switcher}/bin/hyprland-display-switcher";
      };

      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };
}
