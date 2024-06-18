{ lib, config, ... }:
let
  name = "tray";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.enabled.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.enabled.${name}.enable {
    programs.waybar.settings.mainBar."${name}" = {
      spacing = 10;
    };
  };
}
