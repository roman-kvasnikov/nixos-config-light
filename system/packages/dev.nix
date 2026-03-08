{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Git tools
    gh
    lazygit

    # Editors
    micro

    # API / DB tools
    # postman
    # dbeaver-bin
    # tableplus

    # FTP
    # filezilla
  ];
}
