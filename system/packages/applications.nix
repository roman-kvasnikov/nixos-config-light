{pkgs, ...}: {
  # ------------------------------------------------------------
  # APPLICATIONS
  # Пользовательские приложения
  # ------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Browser
    brave

    # File Manager
    yazi

    # Editors / IDE
    code-cursor
    micro

    # Messaging
    telegram-desktop

    # Media
    vlc
    yt-dlp
    cassette

    # Video tools
    ffmpeg
    ffmpegthumbnailer

    # Documents
    evince

    # Graphics
    gimp
    inkscape
    pinta

    # Crypto
    # exodus

    # Dev tools (optional)
    # postman
    # dbeaver-bin
    # tableplus
    # filezilla
  ];
}
