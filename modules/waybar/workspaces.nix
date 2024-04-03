{ lib, config, ... }:
let 
  name = "hyprland/workspaces";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.${name}.enable {
    programs.waybar.settings.mainbar."${name}" = {
      format = "{name}";
      on-click = "activate";
      sort-by = "id";
    };
  };
}
