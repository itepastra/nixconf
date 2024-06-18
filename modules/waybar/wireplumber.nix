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
    programs.waybar.settings.mainBar."${name}" = {
      format = "{volume}% {icon}";
      format-muted = "";
      on-click = "helvum";
      format-icons = [ "" "" "" ];
    };
  };
}
