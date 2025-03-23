{ lib, config, ... }:
let
  name = "memory";
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
        format = " {}%";
        tooltip = false;
      };
      style = ''
        #memory {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 5px 0px;
          padding: 0 8px;
          background-color: #${config.colorScheme.palette.taskbarBackground};
        }
      '';
    };
  };
}
