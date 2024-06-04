{ lib, config, pkgs, ... }:
let
  name = "clock";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.${name}.enable {
    programs.waybar.settings.mainBar.${name} = {
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
        pkgs.gnome.gnome-clocks
      ];
    };
  };
}
