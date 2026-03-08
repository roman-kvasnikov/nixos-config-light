{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Browser
    brave

    # File Manager
    yazi

    # Messaging
    telegram-desktop

    # Media
    vlc
    yt-dlp
    cassette

    # Video
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

    # IDE
    code-cursor
  ];
}
