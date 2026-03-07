{
  inputs,
  system,
  pkgs,
  ...
}: {
  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    # Основные утилиты (должны быть в системе для скриптов)
    curl
    wget
    git
    gh # GitHub CLI
    lazygit # GitHub CLI
    killall
    lm_sensors # Hardware monitoring
    dig

    # SSH утилиты
    ssh-copy-id
    openssh
    rsync

    # Архиваторы (системные зависимости)
    gzip
    p7zip
    zip
    unzip
    unrar

    # Безопасность
    libsecret

    # Мониторинг
    htop
    btop

    inputs.caelestia-shell.packages.${system}.default
  ];
}
