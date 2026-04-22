{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Browser
    brave

    # File Manager
    yazi

    # Messaging
    telegram-desktop

    # Media
    vlc
    mpv
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
    inputs.alejandra.defaultPackage.${pkgs.system}

    gnome-calculator # Calculator
    qalculate-gtk # Calculator
    gnome-calendar # Calendar
    loupe # Image viewer
    decibels # Audio player
    gedit # Text editor
    imagemagick # Image processing

    obs-studio

    auto-cpufreq
  ];
}
