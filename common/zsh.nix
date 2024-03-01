{ config, pkgs, inputs, ... }:

{
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

	programs.kitty = {
		enable = true;
		settings = {
			confirm_os_window_close = 0;
		};
		shellIntegration.enableZshIntegration = true;
	};

}
