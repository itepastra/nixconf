{ lib, config, ... }:
let
  name = "tray";
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
        spacing = 10;
      };
      style = ''
        #tray {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 5px 0px;
          padding: 4px 10px;
          border-radius: 999px;
          background-color: #${config.colorScheme.palette.taskbarBackground};
        }

        #tray > * {
          padding: 0 20px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          background-color: #${config.colorScheme.palette.base08};
          border-radius: 999px;
        }
      '';
    };
  };
}
