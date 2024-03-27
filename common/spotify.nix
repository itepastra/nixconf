{ config, pkgs, inputs, ... }:

{
	services.spotifyd.enable = true;
	home.packages = with pkgs; [
		(symlinkJoin {
			name = "spotify";
			paths = [
				(writeShellScriptBin "spotify" ''${spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland'')
				spotify
			];
		})
	];
}
