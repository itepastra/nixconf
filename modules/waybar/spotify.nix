{ lib, config, pkgs, ... }:
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
        exec = ''${pkgs.playerctl}/bin/playerctl metadata --player=spotify -F -f "{{ status }}: {{ artist }} - {{ title }}"'';
        format = "{}";
        on-click = "${pkgs.playerctl}/bin/playerctl --player=spotify play-pause";
        on-scroll-up = "${pkgs.playerctl}/bin/playerctl --player=spotify volume 0.01+";
        on-scroll-down = "${pkgs.playerctl}/bin/playerctl --player=spotify volume 0.01-";
      };
      style = ''
        #custom-spotify {
          color: #${config.colorScheme.palette.base14};
          margin-right: 10px;
        }
      '';
    };
  };
}
