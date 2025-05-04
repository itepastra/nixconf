{ lib, config, ... }:
let
  name = "cpu";
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
        format = " {usage}%";
        tooltip = false;
      };
      style = ''
        #cpu {
          color: #${config.lib.stylix.colors.base04};
          margin: 5px 0px;
          padding: 0 8px;
          background-color: #${config.lib.stylix.colors.base10};
        }
      '';
    };
  };
}
