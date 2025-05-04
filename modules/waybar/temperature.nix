{ lib, config, ... }:
let
  name = "temperature";
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
      settings.mainBar."${name}" = {
        thermal-zone = 2;
        hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
        critical-threshold = 80;
        format = "{icon} {temperatureC}°C";
        format-icons = [
          ""
          ""
          ""
        ];
      };
      style = ''
        #temperature {
          color: #${config.lib.stylix.colors.base04};
          margin: 5px 0px;
          padding: 0 8px;
          background-color: #${config.lib.stylix.colors.base10};
          border-radius: 0 999px 999px 0;
        }

        #temperature.critcal {
          color: #${config.lib.stylix.colors.base08};
        }
      '';
    };
  };
}
