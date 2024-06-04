{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.dunst;
in
{
  options.modules.dunst = {
    enable = lib.mkEnableOption "enable dunst for notifications";
  };
  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;
    };
  };
}
