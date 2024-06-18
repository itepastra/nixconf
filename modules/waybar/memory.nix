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
        format = "mem: {}%";
        tooltip = false;
      };
      style = ''
        #memory {
          border-radius: 0px;
          padding: 0 10px;
          color: #${config.colorScheme.palette.base04};
          margin: 0px;
          box-shadow: inset 0px 2px 0 -1px #${config.colorScheme.palette.base01},
                inset 0px -2px 0 -1px #${config.colorScheme.palette.base01};
        }
      '';
    };
  };
}
