{ lib, config, ... }:
let
  name = "cpu";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.${name}.enable {
    programs.waybar.settings.mainBar."${name}" = {
      format = "cpu: {usage}%";
      tooltip = false;
    };
  };
}
