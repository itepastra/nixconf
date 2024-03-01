{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		kitty
	];
	programs.kitty = {
		enable = true;
		settings = {
			confirm_os_window_close = 0;
		};
		shellIntegration.enableZshIntegration = true;
	};
}
