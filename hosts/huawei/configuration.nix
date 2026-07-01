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

    # Disable PSR (Power Saving Recommendation) for Intel GPU and Xe GPU (Антимерцание экрана)
    # kernelParams = [
    #   "i915.enable_psr=0"
    #   "xe.enable_psr=0"
    # ];
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
        # intel_pstate active mode → только powersave/performance.
        # powersave здесь = автономный HWP, политику задаёт EPP ниже.
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # EPP (HWP.EPP) — собственно баланс perf/энергия
        # performance | balance_performance | balance_power | power
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power"; # "power" — если важнее автономность, чем отзывчивость

        # P-state limits, % от доступной производительности
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 80; # см. примечание про race-to-idle

        # Turbo boost: 1 = разрешить (не значит "всегда включён")
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0; # 0 — если хочешь жёстко резать нагрев/кулер на батарее

        # HWP dynamic boost — быстрее реагирует на всплески (Skylake+)
        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        # Battery care
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # Демон от Intel, который мониторит температуру в реальном времени и динамически снижает частоты/power limit когда процессор перегревается.
    thermald = {
      enable = true;
    };
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
