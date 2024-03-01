{ config, pkgs, inputs, ... }:

{

	programs.neovim = {
		enable = true;

		extraLuaConfig = ''
			${builtins.readFile ./init.lua}
		'';
	};
}
