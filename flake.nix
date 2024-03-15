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

    nixvim = {
	url = "github:nix-community/nixvim";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    automapaper = {
	url = "github:itepastra/automapaper";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
	url = "github:hyprwm/Hyprland";
	# inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nix-colors, automapaper, ... }@inputs:
    {
      nixosConfigurations = {
        default = nixpkgs.lib.nixosSystem {
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
        server = nixpkgs.lib.nixosSystem {
	  specialArgs = {
	    inherit inputs; 
	    inherit nix-colors;
	  };
	  modules = [ 
	    ./hosts/server/configuration.nix
	    inputs.home-manager.nixosModules.default
	  ];
	};
      };

    };
}
