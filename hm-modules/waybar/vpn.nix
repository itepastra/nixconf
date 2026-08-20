{ lib, config, ... }:
let
  name = "custom/vpn";
in
{
  options.modules.waybar.modules = import ./addname.nix lib name;
  options.modules.waybar.enabled.${name} = {
    enable = lib.mkEnableOption "enable ${name} waybar module";
  };
  config = lib.mkIf config.modules.waybar.enabled.${name}.enable {
    programs.waybar.settings.mainBar."${name}" = {
      format = "VPN";
      exec = "echo '{\"class\": \"connected\"}'";
      exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
      return-type = "json";
      interval = 5;
    };
  };
}
