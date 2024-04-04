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
			# TODO find if i can make these use the 'current' flake
			utest = "sudo nixos-rebuild test --flake $HOME/nixos#default";
			update = "sudo nixos-rebuild switch --flake $HOME/nixos#default";
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
