{
  config,
  user,
  version,
  ...
}: {
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    sessionVariables = {
      XDG_CONFIG_HOME = config.home.homeDirectory;
      GTK_USE_PORTAL = true;
    };
    stateVersion = version;
  };

  imports = [
    ./modules.nix
    ./modules
  ];
}
