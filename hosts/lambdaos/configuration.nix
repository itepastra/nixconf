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

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
    };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.keyboard.qmk.enable = true;

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    cudaSupport = true;
  };

  networking = {
    hostName = "lambdaOS"; # Define your hostname.
    firewall.allowedTCPPorts = [
      7791 # Pixelflut
      38281 # Archipelago
      2283 # immich
    ];
    firewall.allowedUDPPorts = [
      38281 # Archipelago
    ];
  };

  home-manager = {
    users = {
      "noa" = (import ../../common/home) {
        enableGraphical = true;
        enableFlut = true;
        enableGames = true;
        displays = [
          {
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
      enable = true;
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
    udev = {
      packages = [
        pkgs.via
        pkgs.qmk-udev-rules
      ];
    };
  };

  systemd = {
    timers = {
      "update-flake" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };

    services = {
      "update-flake" = {
        path = with pkgs; [
          git
          openssh
          nix
          nixos-rebuild
        ];
        script = ''
          [[ ! -d '/root/nixconf' ]] && git clone git@github.com:itepastra/nixconf /root/nixconf
          cd /root/nixconf
          git fetch
          git reset --hard origin/main
          git pull
          nix flake update --commit-lock-file
          nixos-rebuild boot -L --flake .
          git push
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;
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
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    pciutils
    file

    gnumake
    gcc

    cudatoolkit
    via
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  systemd.services.nvidia-control-devices = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
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
