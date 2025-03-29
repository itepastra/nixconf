# Edit this configuration file to define what should be installed on
# your system.Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  nix-colors,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/games/steam.nix
    ../../modules/plasma

    ../../common
    ../../common/configuration.nix

    ./rescue.nix
    ./restic.nix
  ];

  age.identityPaths = [ "${config.users.users.noa.home}/.ssh/id_ed25519" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
    };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    cudaSupport = true;
  };

  networking = {
    hostName = "zelden"; # Define your hostname.
    firewall.allowedTCPPorts = [
    ];
    firewall.allowedUDPPorts = [
    ];
  };

  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      wim = {
        isNormalUser = true;
        description = "Wim";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "wireshark"
          "dialout"
        ];
        hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
        openssh.authorizedKeys.keys = [ ];
      };
    };
  };

  home-manager = {
    users = {
      "wim" = (import ../../common/home) {
        enableGraphical = true;
        enableFlut = false;
        enableGames = true;
        displays = [
          {
            # TODO: find display name and resolution
            name = "DP-3";
            horizontal = 2560;
            vertical = 1440;
            horizontal-offset = 2560;
            vertical-offset = 0;
            refresh-rate = 360;
            scale = "1";
          }
        ];
        extraConfig = {
          programs.btop.package = pkgs.btop.overrideAttrs (oldAttrs: {
            cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
              "-DBTOP_GPU=ON"
            ];
          });
        };
      };
      "noa" = (import ../../common/home) {
        enableGraphical = true;
        enableFlut = false;
        enableGames = true;
        displays = [
          {
            # TODO: find display name and resolution
            name = "DP-3";
            horizontal = 2560;
            vertical = 1440;
            horizontal-offset = 2560;
            vertical-offset = 0;
            refresh-rate = 360;
            scale = "1";
          }
        ];
        extraConfig = {
          programs.btop.package = pkgs.btop.overrideAttrs (oldAttrs: {
            cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
              "-DBTOP_GPU=ON"
            ];
          });
        };
      };
      "root" = import ./root.nix;
    };
  };

  modules = {
    plasma.enable = false;
  };

  boot.kernelModules = [
    "nvidia_uvm"
  ];

  services = {
    postgresql = {
      enable = false;
      ensureDatabases = [ "noa" ];
      ensureUsers = [
        {
          name = "noa";
          ensureDBOwnership = true;
        }
      ];
    };
    ollama = {
      enable = true;
      acceleration = "cuda";
      openFirewall = true;
    };
    fail2ban.enable = true;
    hardware = {
      openrgb = {
        enable = true;
      };
    };
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    timers."update-from-flake" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 05:00:00";
        Persistent = true;
      };
    };
    services = {
      "update-from-flake" = {
        path = with pkgs; [
          nixos-rebuild
          git
        ];
        script = ''
          nixos-rebuild boot --flake github:itepastra/nixconf#nuOS
          shutdown -r +5 "System will reboot in 5 minutes"
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        wants = [
          "network-online.target"
        ];
        after = [
          "network-online.target"
        ];
        restartIfChanged = false;
      };
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    pciutils
    file

    gnumake
    gcc

    cudatoolkit
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
