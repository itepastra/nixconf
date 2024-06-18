{ config, pkgs, lib, ... }:
let
  cfg = config.modules.waybar;
in
{
  options.modules.waybar = {
    enable = lib.mkEnableOption "enable waybar";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.waybar;
    };
    modules = {
      left = lib.mkOption {
        type = with lib.types; listOf (enum [ ]);
        default = [ ];
      };
      center = lib.mkOption {
        type = with lib.types; listOf (enum [ ]);
        default = [ ];
      };
      right = lib.mkOption {
        type = with lib.types; listOf (enum [ ]);
        default = [ ];
      };
    };
  };

  imports = [
    ./cpu.nix
    ./vpn.nix
    ./tray.nix
    ./clock.nix
    ./power.nix
    ./memory.nix
    ./window.nix
    ./network.nix
    ./workspaces.nix
    ./temperature.nix
    ./wireplumber.nix
    ../../common/colors.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.waybar = import ./createmodules.nix cfg.modules;
    home.packages = with pkgs; [
      font-awesome
    ];
    programs.waybar = {
      enable = true;
      package = cfg.package;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 39;
          margin-top = 8;
          margin-left = 10;
          margin-right = 10;
          output = [
            "DP-3"
            "DP-2"
          ];
          modules-left = cfg.modules.left;
          modules-center = cfg.modules.center;
          modules-right = cfg.modules.right;
        };
      };
      style = ''
        * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: "Maple Mono NF";
          font-size: 14px;
        }

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

        button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -1px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
        }

        /* https://githbackground: #000000ub.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
          background: inherit;
          border-radius: 999px;
        }

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

        #clock,
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #network,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #mode,
        #idle_inhibitor,
        #custom-vpn,
        #scratchpad,
        #tray,
        #custom-updates,
        #custom-poweroff,
        #mpd {
          color: #${config.colorScheme.palette.base04};
          margin: 0px 2px;
          padding: 0 15px;
          
          border-radius: 999px;
          box-shadow: inset 0 0 0 1px #${config.colorScheme.palette.base01};
        }

        .modules-right > widget:last-child > #battery {
          margin-right: 0px;
        }

        #tray {    
          padding: 4px 10px;        
          border-radius: 999px 999px 999px 999px;
          box-shadow: inset 0px 0px 0 1px #${config.colorScheme.palette.base01};
        }

        #window { 
          margin-left: 6px;
          color: #${config.colorScheme.palette.base04};
        }

        #workspaces {   
          margin: 0 4px;
          padding: 4px 4px;   
          border-radius: 999px;
          box-shadow: inset 0px 0px 0 1px #${config.colorScheme.palette.base01};
        }

        #cpu {
          border-radius: 999px 0px 0px 999px;
          margin-right: 0px;        
        }

        #memory {
          border-radius: 0px;
          padding: 0 10px;
          margin: 0px;
          box-shadow: inset 0px 2px 0 -1px #${config.colorScheme.palette.base01},
                inset 0px -2px 0 -1px #${config.colorScheme.palette.base01};
        }

        #clock {    
          box-shadow: none;
        }


        #battery {    
          min-width: 50px;
          border-radius: 999px;
          box-shadow: inset 0 0 0 1px #${config.colorScheme.palette.base01};
          background-color: #${config.colorScheme.palette.base01};
          transition: all 0.3s;
        }

        #battery.charging, #battery.plugged {   
          color: #${config.colorScheme.palette.base0B}; 
          background-color: transparent;
          animation: batteryCharging 1.2s linear 0s infinite normal forwards,               
        }
        #battery.full {
          animation: batteryFull 7.0s linear 0s infinite normal forwards;    
        }
        #battery.critical:not(.charging) {    
          background-color: #${config.colorScheme.palette.base00};
          animation: batteryCritical 1.2s linear 0s infinite normal forwards;        
        }

        #network {     

        }

        #network.disconnected,
        #pulseaudio.muted {
          transition: all 0.2s;
          color: #${config.colorScheme.palette.base01};
        }

        .custom-spotify {
          color: #${config.colorScheme.palette.base14};
          margin-right: 10px;
        }

        #temperature {
          margin-left: 0px;
          border-radius: 0px 999px 999px 0px;
        }

        #temperature.critical {
          background-color: transparent;
          color: #${config.colorScheme.palette.base08};
        }

        #tray {    
          background-color: transparent;
        }


        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          background-color: #${config.colorScheme.palette.base08};
          border-radius: 999px;
        }

        #scratchpad {
          background: rgba(0, 0, 0, 0.1);
        }
        #scratchpad.empty {
          background-color: transparent;
        }

        tooltip {
          background-color: #${config.colorScheme.palette.base00};
          border: 1px solid;
          border-color: #${config.colorScheme.palette.base04};
          border-radius: 10px;
          color: #${config.colorScheme.palette.base05};
        }
        tooltip label {
          padding: 5px;
        }
      '';
    };
  };
}
