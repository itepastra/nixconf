{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		# needed for the nvim config, neovim itself is a system package already
		ripgrep
	];
	programs.neovim = {
		enable = true;
		defaultEditor = true;

		viAlias = true;
		vimAlias = true;
		vimdiffAlias = true;

		extraLuaConfig = ''
			${builtins.readFile ./init.lua}
		'';
	};
}
