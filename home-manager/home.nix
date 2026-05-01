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
    };
    stateVersion = version;
  };

  imports = [
    ./modules.nix
    ./modules
  ];
}
