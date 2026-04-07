{
  lib,
  config,
  ...
}: {
  options.services.hyprland-display-switcher = {
    enable = lib.mkEnableOption "Hyprland Display Switcher";

    builtinMonitor = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1, 3120x2080@90.00, auto, 1.6";
      description = "Built-in monitor";
    };

    externalMonitor = lib.mkOption {
      type = lib.types.str;
      default = "DP-3, 2560x1440@165.00, auto, 1";
      description = "External monitor";
    };

    fallbackMonitor = lib.mkOption {
      type = lib.types.str;
      default = ", preferred, auto, 1";
      description = "Fallback monitor";
    };
  };
}
