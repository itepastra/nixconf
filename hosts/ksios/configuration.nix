# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ modulesPath, pkgs, inputs, lib, nix-colors, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk-config.nix
      inputs.home-manager.nixosModules.default
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")

      ../../common
    ];

  # LOVE me some blob
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  networking = {
    hostName = "ksiOS"; # Define your hostname.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  nix = {
    settings = {
      # auto optimise every so often
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ ];
      trusted-public-keys = [ ];

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

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    nginx = {
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
        "mail.itepastra.nl" = {
          forceSSL = true;
          enableACME = true;
        };
      };
    };
    roundcube = {
      enable = true;
      hostName = "mail.itepastra.nl";
      extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_server'] = "tls://mail.itepastra.nl";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };
    postfix = {
      relayHost = "mail.voorwaarts.nl";
      relayPort = 587;
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.itepastra.nl";
    domains = [ "itepastra.nl" ];
    debug = true;
    hierarchySeparator = "/";


    loginAccounts = {
      "noa@itepastra.nl" = {
        hashedPasswordFile = "/etc/passwords/noa@itepastra.nl";
        aliases = [ "@itepastra.nl" ];
      };
    };

    certificateScheme = "acme";
    acmeCertificateName = "mail.itepastra.nl";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "noa@voorwaarts.nl";
    certs = {
      "mail.itepastra.nl".extraDomainNames = [ ];
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22 # ssh
    80 # http
    443 # https

    587
    25
  ];
  networking.firewall.allowedUDPPorts = [
    22 # ssh
    80 # http
    443 # https
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
