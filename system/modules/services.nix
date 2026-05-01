{
  pkgs,
  lib,
  user,
  ...
}: {
  services = {
    resolved.enable = true;

    gnome.gnome-keyring.enable = true;

    pipewire = {
      enable = true;

      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    pulseaudio.enable = false;

    udisks2.enable = true;

    gvfs.enable = true;

    geoclue2 = {
      enable = true;

      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };

    upower.enable = true;
  };
}
