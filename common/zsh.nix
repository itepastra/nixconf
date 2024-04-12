{ config, lib, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		zsh
	];
	programs.direnv = {
		enable=true;
		enableZshIntegration=true;
		nix-direnv.enable=true;
	};
	programs.zsh = {
		enable=true;
		shellAliases = {
			ll = "lsd -l";
			lt = "lsd -l --tree";
			update = "nix flake update --commit-lock-file $HOME/nixos && sudo nixos-rebuild switch --flake $HOME/nixos";
		};
		history = {
			path = "${config.xdg.dataHome}/zsh/history";
			size = 10000;
		};
		oh-my-zsh = {
			enable = true;
			plugins = [ "git" ];
			theme = "frisk";
		};
	};

}
