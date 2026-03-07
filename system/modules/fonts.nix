{pkgs, ...}: {
  fonts = {
    fontDir.enable = true;

    fontconfig = {
      enable = true;

      antialias = true;

      hinting = {
        enable = true;
        style = "slight";
      };

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };

    enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.caskaydia-cove
      font-awesome
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
