# Edit this configuration file to define what should be installed on
# your system.Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  nix-colors,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/games/steam.nix
    ../../modules/plasma

    ../../common

    ./rescue.nix
    ./restic.nix
  ];

  age.identityPaths = [ "${config.users.users.noa.home}/.ssh/id_ed25519" ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
      };
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  nix.settings = {
    trusted-users = [ "noa" ];
    sandbox = true;
    show-trace = true;

    system-features = [
      "nixos-test"
      "recursive-nix"
    ];
    sandbox-paths = [ "/bin/sh=${pkgs.busybox-sandbox-shell.out}/bin/busybox" ];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
    cudaSupport = true;
  };

  networking = {
    hostName = "lambdaOS"; # Define your hostname.
    networkmanager.enable = true;
    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      53317 # Localsend
      7791 # Pixelflut
      38281 # Archipelago

      22000 # syncthing

      2283 # immich
    ];
    firewall.allowedUDPPorts = [
      53317
      38281 # Archipelago

      22000 # syncthing
      21027 # syncthing
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    root = {
      hashedPassword = "!";
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

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit nix-colors;
    };
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

  environment = {
    pathsToLink = [ "/share/zsh" ];
    systemPackages = with pkgs; [
      restic
      cudatoolkit
    ];
  };

  # TODO: find list of fonts to install
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    fira-code
    fira-code-symbols
    liberation_ttf
    maple-mono-NF
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ pkgs.niri ];
  };

  programs = {
    nm-applet.enable = true;

    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.system}.niri;
    };
    nix-ld.enable = true;

    nix-ld.libraries = with pkgs; [
      wayland
    ];

    wireshark.enable = true;
  };

  modules = {
    games.steam.enable = true;
    plasma.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;

  security.rtkit.enable = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth = rec {
      enable = true;
      theme = "colorful";
      themePackages = [ (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ theme ]; }) ];
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
      "nvidia_uvm"
    ];

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 100;
      };
    };

  };

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
    desktopManager.cosmic.enable = false;
    pcscd = {
      enable = true; # for yubikey
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    fail2ban.enable = true;
    hardware = {
      openrgb = {
        enable = true;
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    xserver = {
      enable = false;
      xkb = {
        layout = "us";
        variant = "intl";
      };
      videoDrivers = [ "nvidia" ];
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    udev.packages = [ pkgs.yubikey-personalization ];
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

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_27;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  security = {
    polkit.enable = true;
  };

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    switch = {
      enableNg = true;
    };
    rebuild = {
      enableNg = true;
    };
    stateVersion = "23.11"; # Did you read the comment?
  };
}
