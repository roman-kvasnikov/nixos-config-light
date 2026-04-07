{
  user,
  version,
  ...
}: {
  imports = [
    ./modules
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = version;
  };
}
