{pkgs, ...}: {
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
    glib
    glibc
    tree

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

    #
    brave
    code-cursor
    telegram-desktop
    micro

    # Веб и разработка
    postman # API тестирование
    # dbeaver-bin # DB клиент
    tableplus # DB клиент
    filezilla # FTP клиент
  ];
}
