{ lib, config, ... }:
let
  name = "hyprland/workspaces";
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
        format = "{name}";
        on-click = "activate";
        sort-by = "id";
      };
      style = ''
        #workspaces button {    
          transition: all 0.2s;
          padding: 3px 3px 3px 5px;
          margin: 3px;
          min-width: 15px;
          min-height: 15px;
          background-color: transparent;
          color: #${config.colorScheme.palette.base04};
          border-radius: 999px;
        }

        #workspaces button:hover {
          background-color: #${config.colorScheme.palette.base17};
        }

        #workspaces button.active {
          font-weight: bold;
          background-color: #${config.colorScheme.palette.base0E};
        }

        #workspaces button.urgent {
          background-color: #${config.colorScheme.palette.base08};
        }

        #workspaces {   
          margin: 0 4px;
          padding: 4px 4px;   
          border-radius: 999px;
          box-shadow: inset 0px 0px 0 1px #${config.colorScheme.palette.base01};
        }
      '';
    };
  };
}
