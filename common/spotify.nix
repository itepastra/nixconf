{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		(symlinkJoin {
			name = "spotify";
			paths = [
				(writeShellScriptBin "spotify" ''  
					exec ${spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
				'')
				spotify
			];
		})
	];
}
