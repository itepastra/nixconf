{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixpkgs.url = "github:NixOS/nixpkgs/d8e0944e6d2ce0f326040e654c07a410e2617d47";

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    automapaper = {
	url = "github:itepastra/automapaper";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    mineflake = {
      url = "github:nix-community/mineflake";
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

  };

  outputs = { self, nixpkgs, nix-colors, automapaper, disko, home-manager, hyprland, lazy, mineflake, ... }@inputs:
    {
      nixosConfigurations = {
        lambdaOS = nixpkgs.lib.nixosSystem {
	  specialArgs = {
	    inherit inputs; 
	    inherit nix-colors;
	    inherit automapaper;
	  };
	  modules = [ 
	    ./hosts/default/configuration.nix
	    inputs.home-manager.nixosModules.default
	  ];
	};
        NoasServer = nixpkgs.lib.nixosSystem {
	  specialArgs = {
	    inherit inputs; 
	    inherit nix-colors;
	    inherit mineflake;
	  };
	  modules = [ 
	    disko.nixosModules.disko
	    ./hosts/server/configuration.nix
	    inputs.home-manager.nixosModules.default
	  ];
	};
      };

    };
}
