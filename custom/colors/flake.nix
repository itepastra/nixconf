{
  description =
    "a home-manager module to make theming easier.";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  };

  outputs = { self, nixpkgs-lib, color-schemes }:
    import ./. {
      nixpkgs-lib = nixpkgs-lib.lib;
    };
}
