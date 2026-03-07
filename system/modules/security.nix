{
  security = {
    sudo = {
      enable = true;

      wheelNeedsPassword = false; # Отключить пароль для wheel (удобно)
      execWheelOnly = true; # Только wheel может использовать sudo
    };

    apparmor.enable = true;

    rtkit.enable = true;

    polkit.enable = true;

    protectKernelImage = true;
  };
}
