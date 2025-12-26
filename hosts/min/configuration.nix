{
  config,
  lib,
  ...
}:
{
  imports = [
    ../lambdaos/disk-config.nix
    ../../common/boot.nix
  ];

  networking.useDHCP = lib.mkDefault true;
  networking = {
    hostName = "lambdaOS"; # Define your hostname.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  users.users = {
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

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
