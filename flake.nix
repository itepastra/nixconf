{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    # nix based ssg
    nixsg.url = "github:itepastra/nixsg/no-md-parser";
    #nixsg.url = "/home/noa/Documents/programming/nixsg";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for secret management
    agenix.url = "github:ryantm/agenix";
    # SSO thingy
    authentik.url = "github:nix-community/authentik-nix";
    # Wallpaper
    automapaper = {
      url = "github:itepastra/automapaper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # discord bot for libqalculate
    disqalculate = {
      url = "github:itepastra/disqalculate";
    };
    # various hardware configurations
    hardware.url = "github:NixOS/nixos-hardware/master";
    # pixelflut stress test tool
    tsunami = {
      url = "github:itepastra/tsunami";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # pixelflut server
    flurry = {
      url = "github:itepastra/flurry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # scrolling window manager
    niri.url = "github:YaLTeR/niri";
    # declarative vencord client
    nixcord.url = "github:kaylorben/nixcord";
    # for styling apps etc in a consistent theme
    stylix.url = "github:danth/stylix";
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
        };
      nixosModules = {
        automapaper = ./modules/automapaper;
      };
      packages = import ./packages { inherit nixpkgs; };
    };
}
