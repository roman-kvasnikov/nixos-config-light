{
  user,
  version,
  ...
}: {
  imports = [
    ./services.nix
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = version;
  };
}
