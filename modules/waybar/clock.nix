{
  lib,
  config,
  pkgs,
  ...
}:
let
  name = "clock";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.enabled.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.enabled.${name}.enable {
    programs.waybar = {
      settings.mainBar.${name} = {
        tooltip-format = "<big>{:%Y %B}</big>\n\n{calendar}";
        interval = 1;
        format = "{:%H:%M:%S}";
        format-alt = "{:%Y-%m-%d %H:%M:%S}";
        on-click-middle = "gnome-clocks";
        calendar = {
          weeks-pos = "left";
          format = {
            today = "<span color='#FF6666'><u>{}</u></span>"; # TODO: use nix-colors
            weeks = "<span color='#707A8C'>{}</span>"; # TODO: use nix-colors
          };
        };
        home.packages = [
          pkgs.gnome-clocks
        ];
      };
      style = ''
        #clock {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 0px 2px;
          padding: 0 15px;
          
          border-radius: 999px;
          box-shadow: none;
        }
      '';
    };
  };
}
