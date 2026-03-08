{
  nixpkgs.config = {
    allowUnfree = true;
  };

  imports = [
    ./apps.nix
    ./cli.nix
    ./dev.nix
    ./system.nix
  ];
}
