# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  modulesPath,
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    inputs.flurry.nixosModules.default
    ./disk-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ./dns.nix
    ./syncthing.nix

    ../../modules/home-assistant
    ../../modules/mealie
    ../../modules/forgejo
    ../../modules/calendar
    ../../modules/immich

    ((import ../../common) { enableGraphics = false; })
  ];

  # LOVE me some blob
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  networking = {
    hostName = "nuOS"; # Define your hostname.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.disqalculate = { };
  users.users = {
    disqalculate = {
      isSystemUser = true;
      group = "disqalculate";
    };
    noa.extraGroups = [ "libvirt" ];
  };

  boot.kernelPackages = pkgs.linuxPackages;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      git
      zsh
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.zsh.enable = true;

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
    users = {
      "noa" = (import ../../common/home) {
        enableFlut = true;
        extraConfig = {
          programs.btop.package = pkgs.btop-rocm.overrideAttrs (
            finalAttrs: previousAttrs: {
              cmakeFlags = (previousAttrs.cmakeFlags or [ ]) ++ [
                "-DBTOP_GPU=ON"
              ];
              patches = (previousAttrs.patches or [ ]) ++ [ ../../common/home/btop-no-nix-store.patch ];
            }
          );
        };
      };
      "root" = import ../../common/home/root.nix;
    };
  };

  systemd.timers."update-from-flake" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 05:00:00";
      Persistent = true;
    };
  };

  nix = {
    settings = {
      builders-use-substitutes = true;
    };
  };

  systemd.services = {
    "update-from-flake" = {
      path = with pkgs; [
        git
      ];
      serviceConfig = {
        Type = "exec";
        User = "root";
        ExecStart = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild switch --flake github:itepastra/nixconf";
      };
      wants = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
      restartIfChanged = false;
    };

    "disqalculate" = {
      enable = true;
      wants = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
      wantedBy = [ "default.target" ];
      restartTriggers = [ inputs.disqalculate.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${
          inputs.disqalculate.packages.${pkgs.stdenv.hostPlatform.system}.default
        }/bin/disqalculate";
        ExecStop = "${pkgs.busybox}/bin/pkill disqalculate";
        RuntimeDirectory = "disqalculate";
        RootDirectory = "/run/disqalculate";
        User = "disqalculate";
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectProc = "noaccess";
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectSystem = "strict";
        ProtectHostname = true;
        PrivateTmp = true;
        PrivateDevices = true;
        PrivateUsers = true;
        RestrictAddressFamilies = "AF_INET";
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        CapabilityBoundingSet = "";
        EnvironmentFile = config.age.secrets."discord/disqalculate".path;
        BindReadOnlyPaths = [
          "/nix/store"
          "/etc/ssl"
          "/etc/static/ssl"
          "/etc/resolv.conf"
          "/bin/sh"
        ];
        Restart = "always";
        RestartSec = 10;
        TimeoutStopSec = 10;
      };
      unitConfig = {
        StartLimitInterval = 400;
        StartLimitBurst = 30;
      };
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };

  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = lib.mkMerge [
      {
        "factorio/solrunners".file = ../../secrets/factorio/solrunners.age;
      }
      {
        "discord/disqalculate" = {
          file = ../../secrets/discord/disqalculate.age;
          owner = "disqalculate";
          group = "disqalculate";
        };
      }
    ];
  };

  services = {
    factorio = {
      enable = false;
      # package = pkgs.factorio-headless.override {
      #   versionsJson = ./versions.json;
      # };
      package = pkgs.factorio-headless;
      openFirewall = true;
      public = true;
      nonBlockingSaving = true;
      game-name = "Solrunners - Space Age";
      description = "Running from the sun into space";
      admins = [ "itepastra" ];
      extraSettingsFile = config.age.secrets."factorio/solrunners".path;
    };
    flurry = {
      enable = (import ./toggles.nix).enableFlurry;
      package = inputs.flurry.packages.${pkgs.stdenv.hostPlatform.system}.default;
      host = "0.0.0.0";
      openFirewall = true;
      grid_width = 1280;
      grid_height = 1024;
      features = [
        "text"
        "binary"
        "palette"
      ];
    };
    i2pd = {
      enable = true;
      settings = {
        ipv4 = true;
        bandwidth = 256;
        port = 19494;
        http.enabled = true;
        sam.enabled = true;
        httpproxy.enabled = true;
        socksproxy.enabled = true;
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # ssh

    19494 # i2p

    22000 # syncthing

    38281 # archipelago
  ];
  networking.firewall.allowedUDPPorts = [
    22 # ssh

    19494 # i2p

    22000 # syncthing
    21027 # syncthing
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}
