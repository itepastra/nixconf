# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  modulesPath,
  pkgs,
  inputs,
  lib,
  nix-colors,
  config,
  ...
}:
let
  enableFlurry = false;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ./disk-config.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    ./home-assistant.nix

    ../../common
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
  users.defaultUserShell = pkgs.zsh;
  users.groups.disqalculate = { };
  users.users = {
    disqalculate = {
      isSystemUser = true;
      group = "disqalculate";
    };
    noa = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
        "libvirt"
      ];
      hashedPassword = "$6$rounds=512400$g/s4dcRttXi4ux6c$Z6pKnhJXcWxv0TBSMtvJu5.piETdUBSgBVN7oDPKiQV.lbTYz1r.0XQLwMYxzcvaaX0DL6Iw/SEUTiC2M50wC/";
      openssh.authorizedKeys.keys = import ../../common/ssh-keys.nix;
    };
  };

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
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.zsh.enable = true;

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit nix-colors;
    };
    users = {
      "noa" = (import ../../common/home) {
        enableFlut = true;
      };
      "root" = import ./root.nix;
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

    "flurry" = {
      enable = enableFlurry;
      description = "Pixelflut server";
      serviceConfig = {
        ExecStart = "${
          inputs.flurry.packages.${pkgs.system}.default.overrideAttrs (
            finalAttrs: previousAttrs: {
              patches = [
                (pkgs.fetchpatch2 {
                  name = "flurry-server-config.patch";
                  url = "https://github.com/itepastra/flurry/commit/db6019fd1a9b363b090f2fc093d0267a37c0d6ff.patch";
                  hash = "sha256-EoIjx2kN8hDrN7vLc4FyWp7JqOHIgYFR1V3NVdoDtsw=";
                })
              ];
            }
          )
        }/bin/flurry";
        ExecStop = "pkill flurry";
        Restart = "on-failure";
      };
      wants = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
      wantedBy = [ "default.target" ];
    };

    "disqalculate" = {
      wants = [
        "network-online.target"
      ];
      after = [
        "network-online.target"
      ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${inputs.disqalculate.packages.${pkgs.system}.default}/bin/disqalculate";
        ExecStop = "${pkgs.busybox}/bin/pkill disqalculate";
        RuntimeDirectory = "disqalculate";
        RootDirectory = "/run/disqalculate";
        User = "disqalculate";
        NoNewPrivileges = true;
        ProtectHome = true;
        ProtectProc = true;
        ProtectClock = true;
        ProtectKernelLogs = true;
        ProtectSystem = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        CapabylityBoundingSet = true;
        RestrictNamspaces = "";
        CapabilityBoundingSet = "";
        EnvironmentFile = config.age.secrets."discord/disqalculate".path;
        BindReadOnlyPaths = [
          "/nix/store"
          "/etc/ssl"
          "/etc/static/ssl"
          "/etc/resolv.conf"
          "/bin/sh"
        ];
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  virtualisation = {
    docker = {
      enable = true;
    };
    libvirtd = {
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
  };

  age = {
    identityPaths = [ "${config.users.users.noa.home}/.ssh/id_ed25519" ];
    secrets = {
      "secrets/token-flurry".file = ../../secrets/github/flurry.age;
      "secrets/token-anstml".file = ../../secrets/github/anstml.age;
      "secrets/token-nixconf".file = ../../secrets/github/nixconf.age;
      "secrets/nix-store-key".file = ../../secrets/nix-serve/private.age;
      "discord/disqalculate".file = ../../secrets/discord/disqalculate.age;
      "factorio/solrunners".file = ../../secrets/factorio/solrunners.age;
      "rsecrets/radicale" = {
        file = ../../secrets/radicale/htpasswd.age;
        owner = "radicale";
        group = "radicale";
      };
    };
  };

  services = {
    factorio = {
      enable = true;
      package = pkgs.factorio-headless.override {
        #versionsJson = ./versions.json;
      };
      openFirewall = true;
      public = true;
      nonBlockingSaving = true;
      game-name = "Solrunners - Space Age";
      description = "Running from the sun into space";
      admins = [ "itepastra" ];
      extraSettingsFile = config.age.secrets."factorio/solrunners".path;
    };
    github-runners = {
      flurry-runner = {
        enable = true;
        extraPackages = with pkgs; [
          nodejs
          curl
        ];
        name = "flurry-runner";
        replace = true;
        tokenFile = config.age.secrets."secrets/token-flurry".path;
        url = "https://github.com/itepastra/flurry";
      };
      anstml-runner = {
        enable = true;
        extraPackages = with pkgs; [
          nodejs
          curl
        ];
        name = "anstml-runner";
        replace = true;
        tokenFile = config.age.secrets."secrets/token-anstml".path;
        url = "https://github.com/itepastra/anstml";
      };
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    radicale = {
      enable = true;
      settings = {
        server.hosts = [ "[::1]:29341" ];
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.age.secrets."rsecrets/radicale".path;
          htpasswd_encryption = "bcrypt";
        };
      };
    };
    nginx =
      let

        extra = ''
          client_max_body_size 50000M;

          proxy_redirect     off;

          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout       600s;'';
        proxy = name: url: {
          forceSSL = true;
          useACMEHost = name;
          extraConfig = extra;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = url;
          };
        };
      in
      {
        enable = true;
        package = pkgs.nginx.override {
          modules = [ pkgs.nginxModules.brotli ];
        };

        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedBrotliSettings = true;
        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

        virtualHosts = lib.mkMerge [
          ({
            "noa.voorwaarts.nl" = {
              forceSSL = true;
              enableACME = true;
              extraConfig = extra;
              locations."/" = {
                proxyWebsockets = true;
                proxyPass = "http://192.168.42.5:8000";
              };
            };

            "images.noa.voorwaarts.nl" = proxy "noa.voorwaarts.nl" "http://192.168.42.5:2283/";
            "maintenance.noa.voorwaarts.nl" = proxy "noa.voorwaarts.nl" "http://192.168.42.5:5000/";
            "map.noa.voorwaarts.nl" = proxy "noa.voorwaarts.nl" "http://127.0.0.1:8123/";

            "itepastra.nl" = {
              forceSSL = true;
              enableACME = true;
              extraConfig = extra;
              locations."/" = {
                proxyWebsockets = true;
                proxyPass = "http://192.168.42.5:9001/";
              };
            };

            "calendar.itepastra.nl" = proxy "itepastra.nl" "http://[::1]:29341";

            # home-assistant proxy
            "home.itepastra.nl" = proxy "itepastra.nl" "http://[::1]:8123";
          })

          (lib.mkIf enableFlurry {
            "flurry.itepastra.nl" = proxy "itepastra.nl" "http://127.0.0.1:3000";
          })
        ];
      };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "noa@voorwaarts.nl";
    certs = {
      "noa.voorwaarts.nl".extraDomainNames = [
        "images.noa.voorwaarts.nl"
        "maintenance.noa.voorwaarts.nl"
        "map.noa.voorwaarts.nl"
      ];
      "itepastra.nl".extraDomainNames =
        [
          "locked.itepastra.nl"
          "calendar.itepastra.nl"
          "home.itepastra.nl"
        ]
        ++ [
          (lib.mkIf enableFlurry "flurry.itepastra.nl")
        ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https

    8443 # nifi

    7791 # flurry

    25565 # minecraft
    24454 # minecraft (voice)

    22000 # syncthing
  ];
  networking.firewall.allowedUDPPorts = [
    22 # ssh
    80 # http
    443 # https

    22000 # syncthing
    21027 # syncthing
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
