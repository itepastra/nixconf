# Edit this configuration file to define what should be installed on
# your system.Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, nix-colors, lib, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ../../modules/games/steam.nix
      ../../modules/plasma
      ./disk-config.nix
      ./hardware-configuration.nix

      ../../common
    ];




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
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    nvidia.acceptLicense = true;
  };
  nixpkgs.overlays = [ ];

  networking = {
    hostName = "muOS"; # Define your hostname.
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
      extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
      hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFemc4Pzp7I0y8FHxgRO/c/ReBmXuqXR6CWqbhiQ+0t noa@Noas_flaptop"
      ];
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
    pinentryPackage = pkgs.pinentry-curses;
  };

  xdg.portal.enable = true;

  programs = {
    zsh.enable = true;

    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
  boot = rec {


    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with kernelPackages; [
      v4l2loopback
    ];
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
      "v4l2loopback"
      "nct6775"
      "k10temp"
    ];

    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=2 card_label="OBS Cam" exclusive_caps=1
    '';

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
    pcscd.enable = true; # for yubikey
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    greetd = {
      enable = false;
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
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "intl";
      };
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    flatpak.enable = true;
    udev.packages = [ pkgs.yubikey-personalization ];
  };

  systemd = {

    timers."update-from-flake" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    services."update-from-flake" = {
      path = with pkgs; [
        nixos-rebuild
      ];
      script = ''nixos-rebuild switch --flake github:itepastra/nixconf'';
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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    53317 # Localsend
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