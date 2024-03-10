{ config, pkgs, nix-colors, ... }:

{
	imports = [
		nix-colors.homeManagerModules.default
	];

	# colorScheme = nix-colors.colorSchemes.catppuccin-macchiato;

	colorScheme = {
		slug = "test";
		name = "TestScheme";
		author = "Noa";
		palette = {
			base00 = "#000000";
			base01 = "#0000FF";
			base02 = "#00FF00";
			base03 = "#00FFFF";
			base04 = "#FF0000";
			base05 = "#FF00FF";
			base06 = "#FFFF00";
			base07 = "#FFFFFF";
			base08 = "#777777";
			base09 = "#7777FF";
			base0A = "#77FF77";
			base0B = "#77FFFF";
			base0C = "#FF7777";
			base0D = "#FF77FF";
			base0E = "#FFFF77";
			base0F = "#AAAAAA";
			text = "#FFFFFF";
			warn = "#FF0000";
			background = "#000000";
		};
	};

}
