{ config, pkgs, inputs, ... }:

{
	services.hypridle = {
		enable = true;
		# TODO: find commands to turn on/off monitors
	};
}
