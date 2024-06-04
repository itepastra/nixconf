{ lib, config, pkgs, ... }:
let
  cfg = config.modules.apps.kitty;
in
{
  options.modules.apps.kitty = {
    enable = lib.mkEnableOption "enable the kitty terminal emulator";
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
      };
      shellIntegration.enableZshIntegration = true;
    };
  };
}
