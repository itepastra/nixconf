{ lib, config, ... }:
let
  name = "wireplumber";
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
        format = "{volume}% {icon}";
        format-muted = "";
        on-click = "helvum";
        format-icons = [
          ""
          ""
          ""
        ];
      };
      style = ''
        #wireplumber {
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
