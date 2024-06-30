{ lib, config, ... }:
let
  name = "hyprland/window";
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
        max-length = 36;
      };
      style = ''
        window#waybar {
          background-color: transparent;
          border-radius: 999px;
          color: #${config.colorScheme.palette.base05};
          transition-property: background-color;
          transition-duration: .5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        window#waybar.termite {
          background-color: transparent;
        }

        window#waybar.chromium {
          background-color: transparent;
        }

        #window { 
          margin-left: 6px;
          color: #${config.colorScheme.palette.taskbarText};
        }
      '';
    };
  };
}
