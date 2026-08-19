{ config, ... }: {
  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
      };
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    graphics.enable = true;
  };

  nixpkgs = {
    config = {
      nvidia.acceptLicense = true;
      cudaSupport = true;
    };
    overlays = [
      (final: prev: {
        btop = (prev.btop.override { cudaSupport = true; }).overrideAttrs (oldAttrs: {
          cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
            "-DBTOP_GPU=ON"
          ];
        });
      })
    ];
  };

  boot.kernelModules = [
    "nvidia_uvm"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
