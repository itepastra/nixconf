{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		(callPackage ../../custom/automapaper/default.nix { })
	];

	home.file = {
		"${config.xdg.configHome}/automapaper/config.toml".source = ./config.toml;
		"${config.xdg.configHome}/automapaper/config2nd.toml".source = ./config2nd.toml;
		"${config.xdg.configHome}/automapaper/state.frag".source = ./state.frag;
		"${config.xdg.configHome}/automapaper/init.frag".source = ./init.frag;
		"${config.xdg.configHome}/automapaper/display.frag".source = ./display.frag;
	};
}
