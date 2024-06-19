{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.plasma;
in
{
  options.modules.plasma = {
    enable = lib.mkEnableOption "enable kde plasma 6";
  };

  imports = [
		../applications
  ];


  config = lib.mkIf cfg.enable {
		modules.apps.enable = true;
		services.desktopManager.plasma6.enable = true;

		xdg.portal.config.common.default = "*";
	};
}
