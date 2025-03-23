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
        format-wifi = "󰖩";
        format-ethernet = "󰲝";
        tooltip-format = "ssid : {essid}\naddr : {ipaddr}/{cidr}\ngate : {gwaddr}\ndev  : {ifname}";
        format-linked = "󰲝";
        format-disconnected = "";
        format-alt = "{ipaddr}/{cidr}";
      };
      style = ''
        #network {
            color: #${config.colorScheme.palette.taskbarText};
            margin: 5px 0px;
            padding: 0 8px;
            background-color: #${config.colorScheme.palette.taskbarBackground};
        }

        #network.disconnected {
          transition: all 0.2s;
          color: #${config.colorScheme.palette.base02};
        }
      '';
    };
  };
}
