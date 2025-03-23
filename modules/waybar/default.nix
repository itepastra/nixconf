{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.waybar;
in
{
  options.modules.waybar = {
    enable = lib.mkEnableOption "enable waybar";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.waybar.override {
        cavaSupport = false;
        hyprlandSupport = false;
        pulseSupport = false;
        swaySupport = false;
      };
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
    ./spotify.nix
    ./battery.nix
    ./bluetooth.nix
    ../../common/colors.nix
  ];

  config = lib.mkIf cfg.enable {
    modules.waybar.enabled = (
      let
        mods = config.modules.waybar.modules;
        allmodules = mods.left ++ mods.center ++ mods.right;
        namedmodules = builtins.map (n: {
          name = n;
          value = {
            enable = true;
          };
        }) allmodules;
        createmodules = builtins.listToAttrs namedmodules;
      in
      createmodules
    );

    home.packages = with pkgs; [
      font-awesome
    ];
    programs.waybar = {
      enable = true;
      package = cfg.package;
      systemd = {
        enable = true;
      };
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 39;
          margin-top = 8;
          margin-left = 10;
          margin-right = 10;
          # TODO: find a new way to do outputs nicely
          # output = builtins.map (display: display.name) config.modules.hyprland.displays;
          modules-left = cfg.modules.left;
          modules-center = cfg.modules.center;
          modules-right = cfg.modules.right;
        };
      };
      style = ''
        * {
          font-family: "Maple Mono NF";
          font-size: 12px;
        }

        window#waybar {
          background-color: transparent;
          color: #${config.colorScheme.palette.taskbarText};
          transition-property: background-color;
          transition-duration: 0.5s;
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

        button:hover {
          background: inherit;
          border-radius: 999px;
        }

        tooltip {
          background-color: #${config.colorScheme.palette.base00};
          border: 1px solid;
          border-color: #${config.colorScheme.palette.taskbarText};
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
