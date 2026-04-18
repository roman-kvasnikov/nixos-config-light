{
  description = "Roman-Kvasnikov's NixOS System Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    alejandra = {
      url = "github:kamadorueda/alejandra/4.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
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

    makeHome = host:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${host.system};
        extraSpecialArgs = {
          inherit user inputs;
          inherit (host) hostname version;
        };
        modules = [
          ./home-manager/home.nix
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

    homeConfigurations = builtins.listToAttrs (
      map (host: {
        name = "${user.name}@${host.hostname}";
        value = makeHome host;
      })
      hosts
    );
  };
}
