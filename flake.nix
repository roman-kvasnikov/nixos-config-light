{
  description = "Roman-Kvasnikov's NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    shared = import ./shared.nix;
    inherit (shared) hosts user;

    makeSystem = host:
      nixpkgs.lib.nixosSystem {
        inherit (host) system;

        specialArgs = {
          inherit inputs user;
          inherit (host) hostname system version;
        };

        modules = [
          ./hosts/${host.hostname}/configuration.nix
        ];
      };
  in {
    nixosConfigurations = builtins.listToAttrs (
      map (host: {
        name = host.hostname;
        value = makeSystem host;
      })
      hosts
    );
  };
}
