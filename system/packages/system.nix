{pkgs, ...}: {
  # ------------------------------------------------------------
  # SYSTEM / CORE UTILITIES
  # Базовые утилиты системы и CLI инструменты
  # ------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Network / downloads
    curl
    wget
    dig
    doggo
    gping

    # Git
    git
    gh
    lazygit

    # Core system
    killall
    glib
    glibc
    bash

    # Shell / CLI environment
    fish
    starship

    # File tools
    tree
    trash-cli

    # JSON / text
    jq
    bat

    # CLI replacements
    eza
    ripgrep
    fd
    dust
    duf
    procs

    # Calculators
    bc
    calc
    libqalculate

    # Monitoring
    htop
    btop
    fastfetch
    lm_sensors
    iotop
    nethogs

    # Bench / analysis
    hyperfine
    tokei

    # Filesystem / cloud
    s3fs
    inotify-tools

    # SSH / sync
    openssh
    ssh-copy-id
    rsync

    # Archives
    gzip
    zip
    unzip
    p7zip
    unrar

    # Security
    libsecret
  ];
}
