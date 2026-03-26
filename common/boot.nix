{
  lib,
  ...
}:
{
  boot = {
    tmp.cleanOnBoot = true;
    consoleLogLevel = 0;
    initrd.verbose = false;

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 100;
      };
    };

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "i915.fastboot=1"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    kernelModules = [
      "nct6775"
      "k10temp"
    ];

  };
}
