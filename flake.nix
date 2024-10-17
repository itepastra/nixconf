{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    # nixpkgs.url = "/home/noa/programming/nixpkgs";

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

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";
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
    };

    cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "oxalica";
      };
    };

  };

  outputs = { self, nixpkgs, nix-colors, automapaper, disko, hyprland, lazy, ... }@inputs:
    {
      nixosConfigurations = {
        lambdaOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit nix-colors;
            inherit automapaper;
          };
          modules = [
            {
              nix.settings = {
                substituters = [ " https://cosmic.cachix.org/ " ];
                trusted-public-keys = [ " cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE= " ];
              };
            }
            ./hosts/lambdaos/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.cosmic.nixosModules.default
            inputs.agenix.nixosModules.default
          ];
        };
        nuOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit nix-colors;
          };
          modules = [
            disko.nixosModules.disko
            inputs.mailserver.nixosModules.default
            ./hosts/nuos/configuration.nix
            inputs.home-manager.nixosModules.default
          ];
        };
        muOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit nix-colors;
            inherit automapaper;
          };
          modules = [
            disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            inputs.hardware.nixosModules.framework-11th-gen-intel
            ./hosts/muos/configuration.nix
          ];
        };
        ksiOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            inherit nix-colors;
          };
          modules = [
            disko.nixosModules.disko
            inputs.mailserver.nixosModules.default
            inputs.home-manager.nixosModules.default
            ./hosts/ksios/configuration.nix
          ];
        };
      };
      nixosModules = {
        automapaper = ./modules/automapaper;
      };
      hydraJobs = {
        inherit (self)
          nixosConfigurations;
      };
    };
}

