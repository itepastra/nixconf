{ lib, config, pkgs, ... }:
let
	cfg = config.modules.games;
in
{
	options.modules.games = {
		enable = lib.mkEnableOption "enable gaming services";
	};

	config = lib.mkIf cfg.enable {

		home.packages = [
			pkgs.prismlauncher
		];

	};
}
