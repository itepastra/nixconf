{
  lib,
  config,
  pkgs,
  ...
}:
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
        scrollback_lines = 5000;
        background_opacity = 0.2;
      };
      shellIntegration = {
        enableZshIntegration = true;
        enableBashIntegration = true;
      };
      font = {
        name = "Maple Mono NF";
        package = pkgs.maple-mono.NF;
      };
    };
  };
}
