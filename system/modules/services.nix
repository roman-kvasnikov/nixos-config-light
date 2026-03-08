{
  pkgs,
  lib,
  user,
  ...
}: {
  services = {
    pipewire = {
      enable = true;

      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    pulseaudio.enable = false;

    udisks2.enable = true;

    gvfs.enable = true;

    geoclue2.enable = true;

    xray = {
      enable = true;

      settingsFile = "/etc/xray/config.json";
    };
  };
}
