{
  security = {
    sudo = {
      enable = true;

      wheelNeedsPassword = false; # Отключить пароль для wheel (удобно)
      execWheelOnly = true; # Только wheel может использовать sudo
    };

    apparmor.enable = false; # TODO: Enable later. Сейчас не билдится из за ошибки в nixpkgs.

    rtkit.enable = true;

    polkit.enable = true;

    protectKernelImage = true;
  };
}
