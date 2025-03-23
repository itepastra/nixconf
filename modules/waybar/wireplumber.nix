{
  lib,
  config,
  pkgs,
  ...
}:
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
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = [
          ""
          ""
          ""
        ];
        on-click = lib.meta.getExe' pkgs.helvum "helvum";
      };
      style = ''
        #wireplumber {
          color: #${config.colorScheme.palette.taskbarText};
          margin: 5px 0px;
          padding: 0 8px;
          background-color: #${config.colorScheme.palette.taskbarBackground};
        }
      '';
    };
  };
}
