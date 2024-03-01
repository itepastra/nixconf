{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		(symlinkJoin {
			name = "discord";
			paths = [
				(writeShellScriptBin "discord" ''${discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland'')
				(writeShellScriptBin "Discord" ''${discord}/bin/Discord --enable-features=UseOzonePlatform --ozone-platform=wayland'')
				discord
			];
		})
	];
}
