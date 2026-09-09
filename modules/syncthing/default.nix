{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ../../config/info
    inputs.home-manager.nixosModules.default
  ];
  networking.firewall = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };

  services.syncthing = lib.mkIf (!config.hardware.graphics.enable) {
    enable = true;
    guiAddress = "127.0.0.1:8384";
  };

  home-manager.users."noa" = lib.mkIf config.hardware.graphics.enable ../../hm-modules/syncthing;
}
