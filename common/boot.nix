{
  lib,
  ...
}:
{
  boot.loader = {
    timeout = lib.mkDefault 0;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      editor = false;
      configurationLimit = 100;
    };
  };
}
