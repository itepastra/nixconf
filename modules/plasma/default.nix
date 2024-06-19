{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.plasma;
in
{
  options.modules.plasma = {
    enable = lib.mkEnableOption "enable kde plasma 6";
  };

  imports = [
  ];

  config = lib.mkIf cfg.enable {
		services.desktopManager.plasma6.enable = true;
	};
}
