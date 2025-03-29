{
  pkgs,
  ...
}:
{
  home = {
    homeDirectory = "/home/wim";
    packages = with pkgs; [
      # Add programs you want installed here if they don't have a `programs` entry
      firefox
      mtr
    ];
    preferXdgDirectories = true;
    stateVersion = "23.11";
    username = "wim";
  };

  xdg = {
    enable = true;
    portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      config.common.default = "*";
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    home-manager.enable = true;
    man.enable = true;
    ssh = {
      enable = true;
      compression = true;
      # you can add matchBlocks from the ssh config here to your liking
      matchBlocks = {
        # "github" = {
        #   host = "github.com";
        #   hostname = "github.com";
        #   identityFile = "~/.ssh/id_rsa_yubikey.pub";
        #   identitiesOnly = true;
        #   port = 22;
        #   user = "git";
        # };
      };
    };
  };
}
