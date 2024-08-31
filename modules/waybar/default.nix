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
    ./spotify.nix
    ../../common/colors.nix
  ];

  config =
    let
      displays_raw = config.modules.hyprland.displays;
      displays = builtins.map (display_raw: builtins.head (lib.strings.splitString "," display_raw)) displays_raw;
    in
    lib.mkIf cfg.enable
      {
        modules.waybar.enabled = (
          let
            mods = config.modules.waybar.modules;
            allmodules = mods.left ++ mods.center ++ mods.right;
            namedmodules = builtins.map
              (n: { name = n; value = { enable = true; }; })
              allmodules;
            createmodules = builtins.listToAttrs namedmodules;
          in
          createmodules
        );

        home.packages = with pkgs;
          [
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
              output = displays;
              modules-left = cfg.modules.left;
              modules-center = cfg.modules.center;
              modules-right = cfg.modules.right;
            };
          };
          style = ''
            * {
              font-family: "Maple Mono NF";
              font-size: 14px;
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
      }
  ;
}
