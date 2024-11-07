{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.wofi;
in
{
  options.modules.wofi = {
    enable = lib.mkEnableOption "enable wofi app launcher";
  };
  imports = [
    ../common/colors.nix
  ];
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      (writeShellScriptBin "wofi-launch" ''
        ${wofi}/bin/wofi --show drun
      '')
      (writeShellScriptBin "wofi-power" ''
        lock="Lock"
        poweroff="Poweroff"
        reboot="Reboot"
        sleep="Suspend"
        logout="Log out"
        selected_option=$(echo -e "$lock\n$sleep\n$reboot\n$logout\n$poweroff" | wofi --dmenu -i -p "Powermenu")

        if [ "$selected_option" == "$lock" ]
        then
        echo "lock"
        swaylock
        elif [ "$selected_option" == "$poweroff" ]
        then
        echo "poweroff"
        poweroff
        elif [ "$selected_option" == "$reboot" ]
        then
        echo "reboot"
        reboot
        elif [ "$selected_option" == "$sleep" ]
        then
        echo "sleep"
        suspend
        elif [ "$selected_option" == "$logout" ]
        then
        echo "logout"
        hyprctl dispatch exit
        else
        echo "No match"
        fi
      '')
    ];
    programs.wofi = {
      enable = true;
      settings = { };
      style = ''
        * {
        outline: none;
        outline-style: none;
        }

        #window {
        margin: 10px;
        border: none;
        background-color: #${config.colorScheme.palette.base01};
        border-radius: 10px;
        font-family:
        JetBrains Mono NF,
        monospace;
        font-weight: bold;
        font-size: 14px;
        }

        #outer-box {
        margin: 10px;
        border: 2px #${config.colorScheme.palette.base00};
        border-radius: 10px;
        background-color: transparent;
        }

        #input {
        border: none;
        border-radius: 10px;
        margin-left: 2px;
        color: #${config.colorScheme.palette.base05};
        outline-style: none;
        background-color: #${config.colorScheme.palette.base03};
        }

        #scroll {
        border: 5px solid #${config.colorScheme.palette.base02};
        border-radius: 10px;
        /*padding-right: 10px;*/
        outline: none;
        background-color: #${config.colorScheme.palette.base00};
        }

        #inner-box {
        border: none;
        border-radius: 10px;
        background-color: transparent;
        }

        #entry {
        border: none;
        border-radius: 10px;
        margin-right: 15px;
        margin-left: 15px;
        padding-right: 10px;
        padding-left: 10px;
        color: #${config.colorScheme.palette.base05};
        background-color: #${config.colorScheme.palette.base00};
        }
        #entry:selected {
        border: none;
        background-color: #${config.colorScheme.palette.base02};
        }

        #text:selected {
        border: none;
        color: #${config.colorScheme.palette.base05};
        }

        #img {
        background-color: transparent;
        margin-right: 6px;
        }
      '';
    };
  };
}
