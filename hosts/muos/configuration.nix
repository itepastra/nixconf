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

    ../../common
    ../../common/configuration.nix

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
      };
      "root" = import ./root.nix;
    };
  };

  services = {
    fprintd.enable = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
