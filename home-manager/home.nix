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
      GTK_USE_PORTAL = "1";
    };
    stateVersion = version;
  };

  imports = [
    ./modules.nix
    ./modules
  ];
}
