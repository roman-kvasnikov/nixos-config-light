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
    thermald = {
      enable = true;

      configFile = pkgs.writeText "thermal-conf.xml" ''
        <?xml version="1.0"?>
        <ThermalConfiguration>
          <Platform>
            <Name>Huawei Cool Profile</Name>
            <ProductName>*</ProductName>
            <Preference>QUIET</Preference>

            <!-- PPCC: ставим максимум на уровне дефолта платформы (28W),
                 чтобы thermald не ругался. Реальное ограничение до 20W
                 делаем через первый trip point ниже. -->
            <PPCC>
              <PowerLimitIndex>0</PowerLimitIndex>
              <PowerLimitMaximum>28000</PowerLimitMaximum>
              <PowerLimitMinimum>8000</PowerLimitMinimum>
              <TimeWindowMinimum>8</TimeWindowMinimum>
              <TimeWindowMaximum>28</TimeWindowMaximum>
              <StepSize>500</StepSize>
            </PPCC>

            <ThermalZones>
              <ThermalZone>
                <Type>x86_pkg_temp</Type>
                <TripPoints>

                  <!-- 55°C: потолок PL1 = 20W.
                       В idle температура ниже, лимит свободен;
                       как только нагрузишь CPU — сразу зажимается. -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>55000</Temperature>
                    <type>passive</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <type>rapl_controller</type>
                      <influence>100</influence>
                      <SamplingPeriod>5</SamplingPeriod>
                      <TargetState>20000000</TargetState>
                    </CoolingDevice>
                  </TripPoint>

                  <!-- 70°C: 15W -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>70000</Temperature>
                    <type>passive</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <type>rapl_controller</type>
                      <influence>90</influence>
                      <SamplingPeriod>4</SamplingPeriod>
                      <TargetState>15000000</TargetState>
                    </CoolingDevice>
                  </TripPoint>

                  <!-- 78°C: 12W -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>78000</Temperature>
                    <type>passive</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <type>rapl_controller</type>
                      <influence>80</influence>
                      <SamplingPeriod>3</SamplingPeriod>
                      <TargetState>12000000</TargetState>
                    </CoolingDevice>
                  </TripPoint>

                  <!-- 85°C: критика, жмём до 8W -->
                  <TripPoint>
                    <SensorType>x86_pkg_temp</SensorType>
                    <Temperature>85000</Temperature>
                    <type>passive</type>
                    <ControlType>SEQUENTIAL</ControlType>
                    <CoolingDevice>
                      <type>rapl_controller</type>
                      <influence>100</influence>
                      <SamplingPeriod>2</SamplingPeriod>
                      <TargetState>8000000</TargetState>
                    </CoolingDevice>
                  </TripPoint>

                </TripPoints>
              </ThermalZone>
            </ThermalZones>
          </Platform>
        </ThermalConfiguration>
      '';
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
