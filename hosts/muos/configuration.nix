# Edit this configuration file to define what should be installed on
# your system.Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ((import ../../common) { enableGraphics = true; })

    ./disk-config.nix
  ];

  powerManagement.enable = true;

  networking.hostName = "muOS";

  home-manager = {
    users = {
      "noa" = (import ../../common/home) {
        enableGraphical = true;
        enableFlut = false;
        enableGames = true;
        displays = [
          {
            name = "eDP-1";
            horizontal = 2256;
            vertical = 1504;
            horizontal-offset = 0;
            vertical-offset = 0;
            refresh-rate = 60;
            scale = "1";
          }
        ];
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

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
    tlp.enable = true;
    power-profiles-daemon.enable = false;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    printing = {
      enable = true;
      browsing = true;
    };
    ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
      openFirewall = true;
    };
    open-webui = {
      enable = true;
      package = pkgs.open-webui.overrideAttrs (
        finalAttrs: previousAttrs: {
          buildInputs = previousAttrs.buildInputs ++ [
            pkgs.repomix
            pkgs.git
          ];
        }
      );
    };
  };

  age.secrets."wg/muos" = {
    file = ../../secrets/wg/muos.age;
  };

  networking.wg-quick.interfaces = {
    wg-pep = {
      address = [
        "10.90.14.2/16"
        "fc00:90:90:90::14:2/64"
      ];
      privateKeyFile = config.age.secrets."wg/muos".path;
      dns = [
        "10.90.0.1"
        "fc00:90:90:90::1"
      ];
      peers = [
        {
          publicKey = "NNeWO/cXpvBci9n/K1W93jKN4wTeHUXZxsELI2XpWQM=";
          allowedIPs = [
            "10.90.0.0/16"
            "fc00:90:90:90::/64"
          ];
          endpoint = "wg.peppidesu.dev:51820";
          #endpoint = "2a02:a465:8b0a:1:1a10:b9e8:e4a6:3f1d:51820";
        }
      ];
    };
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

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.firewall.allowedTCPPorts = [
    49152
    49153
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
