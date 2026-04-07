{
  lib,
  config,
  pkgs,
  ...
}: let
  hyprlandDisplaySwitcherConfig = config.services.hyprland-display-switcher;
  hyprlandDisplaySwitcher = pkgs.callPackage ./package/package.nix {inherit hyprlandDisplaySwitcherConfig config pkgs;};
in {
  config = lib.mkIf hyprlandDisplaySwitcherConfig.enable {
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
        ExecStart = "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher";

        Environment = [
          "PATH=${lib.makeBinPath [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.hyprland
          ]}"
        ];
      };

      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };

    wayland.windowManager.hyprland.settings = {
      monitor = [
        "${hyprlandDisplaySwitcherConfig.builtinMonitor}"
        "${hyprlandDisplaySwitcherConfig.externalMonitor}"
        "${hyprlandDisplaySwitcherConfig.fallbackMonitor}"
      ];

      exec-once = [
        "${hyprlandDisplaySwitcher}/bin/hyprland-display-switcher"
      ];
    };
  };
}
