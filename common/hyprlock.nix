{ config, pkgs, inputs, ... }:

{
	programs.hyprlock = {
		enable = true;
		# TODO: find commands to turn on/off monitors
	};
}
