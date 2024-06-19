# Edit this configuration file to define what should be installed on
# your system.Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, nix-colors, lib, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/games/steam.nix
      ../../modules/websites
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_8;
    consoleLogLevel = 0;
    initrd.verbose = false;
    plymouth = rec {
      enable = true;
      theme = "colorful";
      themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = [ theme ];})];
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

    loader = {
      timeout = lib.mkDefault 0;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 100;
      };
    };
  };


  # LOVE me some blob
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  nixpkgs.overlays = [ ];

  networking = {
    hostName = "lambdaOS"; # Define your hostname.
  };

  networking.networkmanager.enable = true;

  programs.nm-applet.enable = true;

  nix = {
    settings = {
      # auto optimise every so often
      # auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://hyprland.cachix.org"
        "https://cache.iog.io"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
    optimise.automatic = true;
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };


  # Configure console keymap
  console.keyMap = "us-acentos";

  users.groups.nixpow.members = [ "root" ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    root = {
      hashedPassword = "!";
    };
    noa = {
      isNormalUser = true;
      description = "Noa Aarts";
      extraGroups = [ "networkmanager" "wheel" "nixpow" ];
      hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit nix-colors;
    };
    users = {
      "noa" = import ./home.nix;
      "root" = import ./root.nix;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    zsh
    mangohud
  ];

  # TODO: find list of fonts to install
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    fira-code
    fira-code-symbols
    liberation_ttf
    maple-mono-NF
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  xdg.portal.enable = true;

  programs = {
    zsh.enable = true;

    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      wayland
    ];
  };

  modules = {
    games.steam.enable = true;
    websites = {
      enable = true;
      certMail = "acme@voorwaarts.nl";
      mainDomains = {
        "noa.voorwaarts.nl" = {
          enable = true;
          proxy = "http://127.0.0.1:7792/";
          extra_sites = {
            "images.noa.voorwaarts.nl" = {
              enable = true;
              proxy = "http://127.0.0.1:2283/";
            };
            "testing.noa.voorwaarts.nl" = {
              enable = true;
              proxy = "http://127.0.0.1:8000/";
            };
            "sods.noa.voorwaarts.nl" = {
              enable = true;
              proxy = "http://127.0.0.1:2000/";
            };
          };
        };
      };
    };
  };

  users.defaultUserShell = pkgs.zsh;

  security.rtkit.enable = true;

  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/Hyprland";
          user = "noa";
        };
        default_session = initial_session;
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    syncthing = {
      enable = true;
      user = "noa";
      dataDir = "/home/noa/Sync";
      configDir = "/home/noa/Sync/.config/syncthing";
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "intl";
      };
      videoDrivers = [ "nvidia" ];
    };
    flatpak.enable = true;
  };

  systemd = {
    timers."update-flake" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
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
          [[ ! -d '/root/nixconf' ]] && cd /root && git clone git@github.com:itepastra/nixconf
          cd /root/nixconf
          git pull
          nix flake update --commit-lock-file /root/nixconf
          nixos-rebuild boot --flake .
          git push
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
      };
    };
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  boot.kernelModules = [
    "v4l2loopback"
    "nct6775"
    "k10temp"
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security = {
    polkit.enable = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    53317 # Localsend
    7791 # Pixelflut
  ];
  networking.firewall.allowedUDPPorts = [
    53317
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
