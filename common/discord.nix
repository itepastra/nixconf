{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		(symlinkJoin {
			name = "discord";
			paths = [
				(writeShellScriptBin "discord" ''  
					exec ${discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland
				'')
				(writeShellScriptBin "Discord" ''  
					exec ${discord}/bin/Discord --enable-features=UseOzonePlatform --ozone-platform=wayland
				'')
				discord
			];
		})
	];
}
