{
  config,
  lib,
  pkgs,
  inputs,
  nix-colors,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      useOSProber = true;
      device = "nodev";
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs nix-colors;
    };
    users = {
      "noa" = (
        import ./common/home {
          enableGraphical = true;
          enableFlut = false;
          enableGames = false;
          displays = [
            {
              name = "DP-6";
              horizontal = 3840;
              vertical = 1200;
              horizontal-offset = 0;
              vertical-offset = 0;
              refresh-rate = 100;
              scale = "1";
            }
          ];
          local_inputs = inputs;
          extraConfig = {
            programs.btop.package = pkgs.btop.overrideAttrs (oldAttrs: {
              cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
                "-DBTOP_GPU=ON"
              ];
            });
          };
        }
      );
      "wim" = (import ./wim.nix);
    };
  };

  networking = {
    hostName = "zelden";
    firewall.allowedTCPPorts = [ ];
    firewall.allowedUDPPorts = [ ];
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-qt;
    };

    niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.system}.niri;
    };

    zsh.enable = true;
  };

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    xserver.videoDrivers = [ "nvidia" ];
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    thermald.enable = true;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.execWheelOnly = true;
  };

  system = {
    switch.enableNg = true;
    rebuild.enableNg = true;
    stateVersion = "25.05";
  };

  users.users = {
    wim = {
      isNormalUser = true;
      description = "Wim";
      extraGroups = [
        "wheel"
      ];
    };
    noa = {
      isNormalUser = true;
      description = "Noa Aarts";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "wireshark"
        "dialout"
      ];
      hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
      openssh.authorizedKeys.keys = (import ../../common/ssh-keys.nix);
    };
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_27;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
