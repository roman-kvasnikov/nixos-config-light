{
  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ./applications.nix
    ./system.nix
  ];
}
