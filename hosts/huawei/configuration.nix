{
  pkgs,
  hostname,
  system,
  version,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../system
    ../../desktop/hyprland
  ];

  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

      systemd-boot.enable = false;

      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 10;
        default = "saved"; # Запоминать последний выбор
      };
    };

    initrd.luks.devices = {
      "crypted" = {
        device = "/dev/nvme0n1p9"; # UUID зашифрованного раздела!
        preLVM = true; # LUKS расшифровывается ДО активации LVM
      };
    };
  };

  environment.systemPackages = with pkgs; [
    os-prober
  ];

  services = {
    openssh = {
      enable = false;

      settings = {
        X11Forwarding = false;
      };
    };

    # Энергосбережение ноутбука
    power-profiles-daemon.enable = false;

    tlp = {
      enable = true;

      settings = {
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 70;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
  };

  system.stateVersion = version;
}
