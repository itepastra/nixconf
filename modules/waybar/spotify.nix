{
  lib,
  config,
  pkgs,
  ...
}:
let
  name = "custom/spotify";
in
{
  options.modules.waybar = {
    modules = import ./addname.nix lib name;
    enabled.${name} = {
      enable = lib.mkEnableOption "enable ${name} waybar module";
    };
  };
  config = lib.mkIf config.modules.waybar.enabled.${name}.enable {
    programs.waybar = {
      settings.mainBar.${name} = {
        exec = ''${lib.meta.getExe pkgs.playerctl} metadata --player=spotify -F -f "{{ status }}: {{ artist }} - {{ title }}"'';
        format = "{}";
        on-click = "${lib.meta.getExe pkgs.playerctl} --player=spotify play-pause";
        on-click-middle = lib.meta.getExe' pkgs.spotify "spotify";
        on-scroll-up = "${lib.meta.getExe pkgs.playerctl} --player=spotify volume 0.01+";
        on-scroll-down = "${lib.meta.getExe pkgs.playerctl} --player=spotify volume 0.01-";
      };
      style = ''
        #custom-spotify {
          color: #${config.colorScheme.palette.base14};
          margin: 5px 0px;
          padding: 0 8px;
          background-color: #${config.colorScheme.palette.taskbarBackground};
          border-radius: 0 999px 999px 0;
          transition: all 1s;
        }
      '';
    };
  };
}
