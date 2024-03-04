{ config, pkgs, nix-colors, ... }:

{
	imports = [
		nix-colors.homeManagerModules.default
	];

	colorScheme = nix-colors.colorSchemes.catppuccin-macchiato;

}
