{pkgs, ...}: {
  services = {
    displayManager.sddm = {
      enable = true;

      wayland.enable = true;
      theme = "sddm-astronaut-theme";
      extraPackages = with pkgs; [
        kdePackages.qtmultimedia
        kdePackages.qtsvg
        kdePackages.qt5compat
      ];
    };
  };
}
