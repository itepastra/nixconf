{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
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
      # settings = {
      #   global = {
      #     width = 300;
      #     height = 300;
      #     offset = "30x50";
      #     origin = "top-right";
      #     transparency = 10;
      #     frame_color = "#293929";
      #     font = "Droid Sans 9";
      #   };
      #
      #   urgency_normal = {
      #     background = "#37474f";
      #     foreground = "#293929";
      #     timeout = 10;
      #   };
      # };
    };
  };
}
