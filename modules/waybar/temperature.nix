{ lib, config, ... }:
let 
  name = "temperature";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.${name}.enable {
    programs.waybar.settings.mainbar."${name}" = {
      thermal-zone = 2;
      hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
      critical-threshold = 80;
      format = "{temperatureC}°C {icon}";
      format-icons = ["" "" ""];
    };
  };
}
