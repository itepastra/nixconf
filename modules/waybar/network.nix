{ lib, config, ... }:
let
  name = "network";
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
        format-wifi = "{essid} ({signalStrength}%) 󰖩";
        format-ethernet = "{ipaddr}/{cidr} 󰛳";
        tooltip-format = "{ifname} via {gwaddr} 󰛳";
        format-linked = "{ifname} (No IP) 󰛳";
        format-disconnected = "Disconnected ";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };
      style = ''
        #network {
            color: #${config.colorScheme.palette.taskbarText};
            margin: 0px 2px;
            padding: 0 15px;
            border-radius: 999px;
            box-shadow: inset 0 0 0 1px #${config.colorScheme.palette.base01};
        }

        #network.disconnected,
      '';
    };
  };
}
