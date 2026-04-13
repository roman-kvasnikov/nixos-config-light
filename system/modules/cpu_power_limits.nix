{pkgs, ...}: {
  # Устанавливает undervolt для CPU. (Не работает на Huawei MateBook X Pro)
  # services.undervolt = {
  #   enable = true;
  #   coreOffset = -50;
  #   gpuOffset = -30;
  #   uncoreOffset = -50;
  # };

  # Демон от Intel, который мониторит температуру в реальном времени и динамически снижает частоты/power limit когда процессор перегревается.
  services.thermald.enable = true;

  # Устанавливает power limit для CPU.
  systemd.services.powerlimit = {
    description = "Set CPU power limits";
    after = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 20000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw'";
    };
    wantedBy = ["multi-user.target"];
  };
}
