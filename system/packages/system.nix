{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    home-manager

    # Network
    curl
    wget

    # Core
    git
    openssh
    rsync
    killall

    # Libraries
    glib
    glibc

    # System tools
    lm_sensors
    libsecret

    # Archives
    gzip
    zip
    unzip
    p7zip
    unrar

    samba
    wakeonlan
  ];
}
