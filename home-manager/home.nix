{
  config,
  user,
  version,
  ...
}: {
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = version;
  };

  imports = [
    ./modules.nix
    ./modules
  ];
}
