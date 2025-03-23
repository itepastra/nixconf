{
  lib,
  config,
  ...
}:
let
  name = "battery";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.enabled.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.enabled.${name}.enable {
    programs.waybar = {
      settings.mainBar.${name} = {
        states = {
          full = 100;
          good = 99;
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% {icon}";
        format-plugged = "{capacity}% {icon}";
        format-alt = "{time} {icon}";

        interval = 1;
        format-full = "";
        format-icons = [
          "󰂎"
          "󰁻"
          "󰁾"
          "󰂀"
          "󰁹"
        ];
      };
      style = ''
        #battery {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 5px 2px;
          padding: 0 12px;
          border-radius: 999px;
          min-width: 40px;
          transition: all 0.3s;
          background-color: #${config.colorScheme.palette.taskbarBackground};
        }

        #battery.charging,
        #battery.plugged,
        #battery.full {
          color: #${config.colorScheme.palette.taskbarText};
          background-color: #${config.colorScheme.palette.taskbarBackground};
          box-shadow: none;
        }

        #battery.critical:not(.charging) {
          background-color: transparent;
          animation: batteryCritical 1.2s linear 0s infinite normal forwards;
        }

        @keyframes batteryCritical {
          0% {
            background-color: #${config.colorScheme.palette.base08};
            color: #${config.colorScheme.palette.base06};
          }
          50% {
            background-color: #${config.colorScheme.palette.base02};
            color: #${config.colorScheme.palette.base08};
          }
          100% {
            background-color: #${config.colorScheme.palette.base08};
            color: #${config.colorScheme.palette.base06};
          }
        }
      '';
    };
  };
}
