{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		firefox
	];

	programs.firefox = {
		enable = true;
		# TODO add some default firefox settings
	};

}
