{ lib, config, ... }:
let
  name = "custom/poweroff";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  imports = [
    ../wofi.nix
  ];
  config = lib.mkIf config.modules.waybar.${name}.enable {
    modules.wofi.enable = true;
    programs.waybar.settings.mainBar."${name}" = {
      format = "";
      on-click = "wofi-power";
      on-click-right = "swaylock"; # TODO: change to whatever lock screen i want
    };
  };
}
