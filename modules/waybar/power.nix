{ lib, config, ... }:
let
  name = "custom/poweroff";
in
{
  options.modules.waybar = {
    modules = import ./addname.nix lib name;
    enabled.${name} = {
      enable = lib.mkEnableOption "enable ${name} waybar module";
    };
  };
  imports = [
    ../wofi.nix
  ];
  config = lib.mkIf config.modules.waybar.enabled.${name}.enable {
    modules.wofi.enable = true;
    programs.waybar = {
      settings.mainBar."${name}" = {
        format = "";
        on-click = "wofi-power";
        on-click-right = "swaylock"; # TODO: change to whatever lock screen i want
      };
      style = ''
        #custom-poweroff {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 0px 2px;
          padding: 0 15px;
          border-radius: 999px;
          box-shadow: inset 0 0 0 1px #${config.colorScheme.palette.base01};
        }
      '';
    };
  };
}
