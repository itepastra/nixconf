{ lib, config, ... }:
let
  name = "cpu";
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
        format = "cpu: {usage}%";
        tooltip = false;
      };
      style = ''
        #cpu {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 0px 0px;
          padding: 0 15px;
          
          border-radius: 999px 0px 0px 999px;
          box-shadow: inset 0 0 0 1px #${config.colorScheme.palette.base01};
        }
      '';
    };
  };
}
