{
  lib,
  config,
  pkgs,
  ...
}:
let
  name = "custom/bluetooth";
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
        format = "";
        on-click = lib.meta.getExe' pkgs.blueberry "blueberry";
      };
      style = ''
        #custom-bluetooth {
          color: #${config.lib.stylix.colors.base04};
          margin: 5px 0px;
          padding: 0 8px;
          background-color: #${config.lib.stylix.colors.base10};
          border-radius: 999px 0 0 999px;
        }
      '';
    };
  };
}
