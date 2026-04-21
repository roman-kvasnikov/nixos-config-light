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

    # Устанавливает undervolt для CPU. (Не работает на Huawei MateBook X Pro)
    # undervolt = {
    #   enable = true;
    #   coreOffset = -50;
    #   gpuOffset = -30;
    #   uncoreOffset = -50;
    # };

    # https://wiki.nixos.org/wiki/Laptop

    tlp = {
      enable = true;

      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;

        # Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };
    };

    # Демон от Intel, который мониторит температуру в реальном времени и динамически снижает частоты/power limit когда процессор перегревается.
    thermald.enable = true;
  };

  # Устанавливает power limit для CPU.
  # systemd.services.powerlimit = {
  #   description = "Set Intel RAPL package power limit";

  #   wantedBy = ["multi-user.target" "post-resume.target"];
  #   after = ["multi-user.target" "post-resume.target"];

  #   unitConfig = {
  #     ConditionPathExists = "/sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw";
  #   };

  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };

  #   script = ''
  #     echo 20000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw
  #   '';
  # };

  system.stateVersion = version;
}
