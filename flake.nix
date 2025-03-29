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

    cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
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
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-colors,
      automapaper,
      disko,
      lazy,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        lambdaOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              nix-colors
              automapaper
              ;
          };
          modules = [
            ./hosts/lambdaos/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.cosmic.nixosModules.default
            inputs.agenix.nixosModules.default
            inputs.lix-module.nixosModules.default
          ];
        };
        nuOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              nix-colors
              ;
          };
          modules = [
            disko.nixosModules.disko
            inputs.mailserver.nixosModules.default
            ./hosts/nuos/configuration.nix
            inputs.home-manager.nixosModules.default
            inputs.agenix.nixosModules.default
          ];
        };
        muOS = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              inputs
              nix-colors
              automapaper
              ;
          };
          modules = [
            disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            inputs.hardware.nixosModules.framework-11th-gen-intel
            ./hosts/muos/configuration.nix
          ];
        };
      };
      nixosModules = {
        automapaper = ./modules/automapaper;
      };
      homeManagerModules = {
        "noa@zelden" =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in
          (import ./common/home {
            enableGraphical = true;
            enableFlut = false;
            enableGames = false;
            displays = [
              {
                name = "DP-6";
                horizontal = 3840;
                vertical = 1200;
                horizontal-offset = 0;
                vertical-offset = 0;
                refresh-rate = 100;
                scale = "1";
              }
            ];
            local_inputs = inputs;
            extraConfig = {
              programs.btop.package = pkgs.btop.overrideAttrs (oldAttrs: {
                cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
                  "-DBTOP_GPU=ON"
                ];
              });
            };
          });
      };
      packages = import ./packages { inherit nixpkgs; };
    };
}
