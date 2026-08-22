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

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-analyzer-src.follows = "";
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
    nixpkgs.url = "github:nixos/nixpkgs/master";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
      };
    };

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
    # Wallpaper
    automapaper = {
      url = "git+https://git.geenit.nl/noa/automapaper-ng.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        flake-utils.follows = "flake-utils";
        advisory-db.follows = "advisory-db";
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

    # nix binary cache
    attic = {
      url = "github:zhaofengli/attic";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        crane.follows = "crane";
        flake-compat.follows = "flake-compat";
      };
    };

    # various hardware configurations
    hardware.url = "github:NixOS/nixos-hardware/master";

    # packages grimmory
    tixpkgs = {
      url = "github:74k1/tixpkgs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-parts.follows = "flake-parts";
      };
    };

    # pixelflut stress test tool
    tsunami = {
      url = "git+https://git.geenit.nl/noa/tsunami.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        advisory-db.follows = "advisory-db";
        crane.follows = "crane";
        fenix.follows = "fenix";
        flake-utils.follows = "flake-utils";
      };
    };
    # pixelflut server
    flurry = {
      url = "git+https://git.geenit.nl/noa/flurry.git";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        advisory-db.follows = "advisory-db";
        crane.follows = "crane";
        fenix.follows = "fenix";
        tsunami.follows = "tsunami";
      };
    };
    # alternative nix implementation
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
      inputs.flake-utils.follows = "flake-utils";
    };

    # declarative vencord client
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    prettier-plugins = {
      url = "github:nix-utilities/prettier-with-plugins";
      flake = false;
    };
    # for styling apps etc in a consistent theme
    stylix = {
      url = "github:nix-community/stylix";
      inputs = {
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nur.inputs.flake-parts.follows = "flake-parts";
      };
    };
    # Compositor
    niri = {
      url = "github:niri-wm/niri";
      inputs = {
        nixpkgs.follows = "nixpkgs";
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
            nixvim.nixosModules.nixvim
            lix-module.nixosModules.default
          ];
        in
        {
          xiOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              inputs.hardware.nixosModules.apple-macbook-air-5
              inputs.disko.nixosModules.disko
              ./hosts/xios/configuration.nix
            ];
          };
          lambdaOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
              ./hosts/lambdaos/configuration.nix
            ]
            ++ commonModules;
          };
          nuOS = nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
            };
            modules = [
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
      packages = import ./packages { inherit nixpkgs inputs self; };
      formatter.x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
