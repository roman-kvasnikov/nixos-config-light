{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Shell
    bash
    fish
    starship

    # CLI tools
    jq
    bat
    tree

    # Modern coreutils
    eza
    ripgrep
    fd
    dust
    duf
    procs

    # Monitoring
    htop
    btop
    fastfetch
    iotop
    nethogs

    # Network
    dig
    doggo
    gping

    # Dev utilities
    hyperfine
    tokei

    # Calculators
    bc
    calc
    libqalculate

    # Filesystem
    s3fs
    inotify-tools
    trash-cli

    gnupg
    pass
    pinentry-bemenu
  ];
}
