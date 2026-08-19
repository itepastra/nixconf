{ config, pkgs, ... }: {
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
      allowUnfreePackages = [
        "cuda-merged"
        "cuda_cccl"
        "cuda_cudart"
        "cuda_cuobjdump"
        "cuda_cupti"
        "cuda_cuxxfilt"
        "cuda_gdb"
        "cuda_nvcc"
        "cuda_nvdisasm"
        "cuda_nvml_dev"
        "cuda_nvprune"
        "cuda_nvrtc"
        "cuda_nvtx"
        "cuda_profiler_api"
        "cuda_sanitizer_api"
        "libcublas"
        "libcufft"
        "libcurand"
        "libcusolver"
        "libcusparse"
        "libnpp"
        "libnvjitlink"
        "nvidia-persistenced"
        "nvidia-settings"
        "nvidia-x11"
      ];
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

  environment.systemPackages = [
    pkgs.cudatoolkit
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
