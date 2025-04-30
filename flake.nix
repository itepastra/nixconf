{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "/home/noa/Documents/programming/nixpkgs";

    nix-colors = {
      url = "github:itepastra/nix-colors";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    automapaper = {
      url = "github:itepastra/automapaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lazy = {
      url = "github:bobvanderlinden/nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    agenix = {
      url = "github:ryantm/agenix";
    };

    oxalica = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tsunami = {
      url = "github:itepastra/tsunami";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flurry = {
      url = "github:itepastra/flurry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:YaLTeR/niri";
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    lix = {
      url = "git+https://git.lix.systems/lix-project/lix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:kaylorben/nixcord";
    };
    disqalculate = {
      url = "github:itepastra/disqalculate";
    };

    stylix = {
      url = "github:danth/stylix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        lambdaOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./hosts/lambdaos/configuration.nix
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
            inputs.agenix.nixosModules.default
            inputs.lix-module.nixosModules.default
          ];
        };
        nuOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            disko.nixosModules.disko
            inputs.mailserver.nixosModules.default
            # TODO: find out how I can remove this
            inputs.stylix.nixosModules.stylix
            ./hosts/nuos/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.agenix.nixosModules.default
          ];
        };
        muOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            disko.nixosModules.disko
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
            inputs.hardware.nixosModules.framework-11th-gen-intel
            ./hosts/muos/configuration.nix
          ];
        };
        zelden = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          modules = [
            inputs.home-manager.nixosModules.default
            inputs.stylix.nixosModules.stylix
            ./hosts/zelden/configuration.nix
          ];
        };
      };
      nixosModules = {
        automapaper = ./modules/automapaper;
      };
      packages = import ./packages { inherit nixpkgs; };
    };
}
