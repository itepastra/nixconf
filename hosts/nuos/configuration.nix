# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ modulesPath, pkgs, inputs, lib, nix-colors, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.default
      ./disk-config.nix
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")

      ../../common
    ];

  # LOVE me some blob
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  networking = {
    hostName = "NoasServer"; # Define your hostname.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.

  nix = {
    settings = {
      # auto optimise every so often
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://hyprland.cachix.org"
        "http://192.168.42.5"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "192.168.42.5:+zcyHtRvk2otQhHDrDRNMQhp+j+ziVHHhDToC0wqjHE="
      ];

      allowed-uris = [
        "github:"
        "gitlab:"
      ];
    };
    gc.automatic = false;
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.zsh;
  users.users = {
    noa = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "docker" "libvirt" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDmUSRs2akTTWtiaCcB5PNaLFJlwZmvD8YEZp2R4SQ56gj1xddZ0QP8XQIqRd6cmkaGzS9QzNpo03mlaOUTItFarp+OJh7oe9DcqpLR7+30mdLJgmYC6SOm/Upm9jZbl+YVuRbCWUXJ8pgKeJ+GseiKUx/3nPFPJ17Z7xV1GwPBVDxE4F3TVF/JFn6NYE0NF0I35lYUT8JOrmr7r2+VYBt9Pbqta7G6afTl4ETX/pDDiEHQAsf5dUvF/FdAUp50DMVqC81xPlx/ajMzI4thssA8CkUDZdns7WhWSvDuyCz6bRZhnBqJ0oM9clhljhVq7eAScAEH4mM0XEexlE5NUmGqLZJT7NZIX+SRhxtKMTZBY3y6w6cxgNMo8lAhp0d1mlSmBEB1cvlCr38ZtcAyYA1m3vHwnJ4vsbCxxGZeTyLY+mZC4dFcSSyc+P3DtxBle7q6F/Qc9K53I454YsUVHTzD/K1A6r75/6igQBKEoGScVQX5qFLFWOu0k1hOEV3mT3jzP48l5iEz6whdO0EKbHJT3vvM+vj3zLzJ9YeSTDbxTE0AhMNt17yICB/vX1Fi/SwlwjYgUQnwiKbqkOaT5ZTxcqcv3x0EyTdq43J1TEWcAKUW7nlcQ9rwJnwg6MfUKE/cawwPUqGp8WTbavX4/IX/k+jQsuI9XvZ9Y96ilLhTRw== openpgp:0xD85CD295"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFemc4Pzp7I0y8FHxgRO/c/ReBmXuqXR6CWqbhiQ+0t noa@Noas_flaptop"
      ];
      hashedPassword = "$6$rounds=512400$g/s4dcRttXi4ux6c$Z6pKnhJXcWxv0TBSMtvJu5.piETdUBSgBVN7oDPKiQV.lbTYz1r.0XQLwMYxzcvaaX0DL6Iw/SEUTiC2M50wC/";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      sddm
      git
      zsh
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #	 enable = true;
  #	 enableSSHSupport = true;
  # };


  programs.zsh.enable = true;

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

  systemd.timers."update-from-flake" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.services."update-from-flake" = {
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

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    nix-serve = {
      enable = true;
      secretKeyFile = "/var/cache-priv-key.pem";
      bindAddress = "127.0.0.1";
      port = 22332;
    };
    radicale = {
      enable = true;
      settings = {
        server.hosts = [ "[::1]:29341" ];
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/var/radicale_users";
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

        virtualHosts = {
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

          "fete.voorwaarts.nl" = {
            forceSSL = true;
            enableACME = true;
            extraConfig = extra;
            locations."/" = {
              proxyWebsockets = true;
              proxyPass = "http://[::1]:22000";
            };
          };

          "itepastra.nl" = {
            forceSSL = true;
            enableACME = true;
            extraConfig = extra;
            locations."/" = {
              proxyWebsockets = true;
              proxyPass = "http://192.168.42.5:9001/";
            };
          };

          "pfa.itepastra.nl" = {
            forceSSL = true;
            enableACME = false;
            useACMEHost = "itepastra.nl";
          };

          "locked.itepastra.nl" = {
            forceSSL = true;
            useACMEHost = "itepastra.nl";
            extraConfig = extra;

            locations."/" = {
              proxyWebsockets = true;
              proxyPass = "http://192.168.42.5:9000/";
            };

          };

          "calendar.itepastra.nl" = proxy "itepastra.nl" "http://[::1]:29341";

          "noasserver" = {
            locations."/".proxyPass = "http://127.0.0.1:22332";
          };

        };
      };
    roundcube = {
      enable = true;
      hostName = "rc.itepastra.nl";
      extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_server'] = "tls://mail.itepastra.nl";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
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
      "itepastra.nl".extraDomainNames = [
        "locked.itepastra.nl"
        "pfa.itepastra.nl"
        "calendar.itepastra.nl"
      ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https
    3000 # hydra

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
