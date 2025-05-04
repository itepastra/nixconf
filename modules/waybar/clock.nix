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
        on-click-middle = lib.meta.getExe' pkgs.gnome-clocks "gnome-clocks";
        calendar = {
          weeks-pos = "left";
          format = {
            today = "<span color='#${config.lib.stylix.colors.base17}'><u>{}</u></span>";
            weeks = "<span color='#${config.lib.stylix.colors.base17}'>{}</span>";
          };
        };
      };
      style = ''
        #clock {
          color: #${config.lib.stylix.colors.base04};
          background-color: #${config.lib.stylix.colors.base10};
          margin: 5px 0px;
          padding: 0 12px;
          border-radius: 999px 0 0 999px;
          box-shadow: none;
        }
      '';
    };
  };
}
