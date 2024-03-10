{ nixpkgs-lib, ... }: rec {
  lib-core = import ./lib/core { inherit nixpkgs-lib; };
  lib = lib-core // { contrib = lib-contrib; };

  homeManagerModules = rec {
    colorScheme = import ./module;
    # Alias
    colorscheme = colorScheme;
    default = colorScheme;
  };
  homeManagerModule = homeManagerModules.colorScheme;
}
