{
  description = "Nixos config flake";

  inputs = {
    # transient inputs
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };

    crane = {
      url = "github:ipetkov/crane";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = {
        systems.follows = "systems";
      };
    };

    systems = {
      url = "github:nix-systems/default";
    };

    # main inputs
    nixpkgs.url = "github:nixos/nixpkgs/51be9c59a890463e15d0677cb550787dc0d4bbfe";

    nixsg.url = "github:itepastra/nixsg";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
      };
    };
    # SSO thingy
    authentik = {
      url = "github:nix-community/authentik-nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-compat.follows = "flake-compat";
      };
    };
    # Wallpaper
    automapaper = {
      url = "github:itepastra/automapaper";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    # declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    # discord bot for libqalculate
    disqalculate = {
      url = "github:itepastra/disqalculate";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        advisory-db.follows = "advisory-db";
        crane.follows = "crane";
        flake-utils.follows = "flake-utils";
      };
    };
    # various hardware configurations
    hardware.url = "github:NixOS/nixos-hardware/master";
    # pixelflut stress test tool
    tsunami = {
      url = "github:itepastra/tsunami";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        advisory-db.follows = "advisory-db";
        crane.follows = "crane";
        flake-utils.follows = "flake-utils";
      };
    };
    # pixelflut server
    flurry = {
      url = "github:itepastra/flurry";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        advisory-db.follows = "advisory-db";
        crane.follows = "crane";
        tsunami.follows = "tsunami";
      };
    };
    # alternative nix implementation
    lix = {
      url = "git+https://git.lix.systems/lix-project/lix.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    # module for lix
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        lix.follows = "lix";
        flake-utils.follows = "flake-utils";
      };
    };
    qubit-quilt = {
      url = "github:itepastra/Quantum-surface-application";
    };
    # declarative vencord client
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs = {
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };
    # for styling apps etc in a consistent theme
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nur.inputs.flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    {
      nixosConfigurations =
        let
          commonModules = with inputs; [
            home-manager.nixosModules.default
            stylix.nixosModules.stylix
            agenix.nixosModules.default
            disko.nixosModules.disko
          ];
        in
        {
          lambdaOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              ./hosts/lambdaos/configuration.nix
              inputs.nixsg.nixosModules.nginxSite
            ]
            ++ commonModules;
          };
          nuOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              inputs.authentik.nixosModules.default
              ./hosts/nuos/configuration.nix
            ]
            ++ commonModules;
          };
          muOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              inputs.hardware.nixosModules.framework-amd-ai-300-series
              ./hosts/muos/configuration.nix
            ]
            ++ commonModules;
          };

          alphaOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              ./hosts/min/configuration.nix
              inputs.disko.nixosModules.disko
            ];
          };
        };
      nixosModules = {
        automapaper = ./modules/automapaper;
      };
      packages = import ./packages { inherit nixpkgs; };
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
