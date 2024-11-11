{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
let
  me = {
    nickname = "noa";
    fullName = "Noa Aarts";
    email = "noa@voorwaarts.nl";
  };

  cursor_name = "Bibata-Rainbow-Modern";
  cursor_src = pkgs.fetchzip {
    name = cursor_name;
    url = "https://github.com/ful1e5/Bibata_Cursor_Rainbow/releases/download/v1.1.2/Bibata-Rainbow-Modern.tar.gz";
    hash = "sha256-Ps+IKPwQoRwO9Mqxwc/1nHhdBT2R25IoeHLKe48uHB8=";
  };
in
{
  imports = [
    ../../modules/hyprland.nix
    ../../modules/games
    ../../modules/applications
    ../../common/nvim/nvim.nix
    ../../common/discord/discord.nix
    ../../common/spotify.nix
  ];

  home = {
    file = {
      "programming".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/programming/";
    };
    homeDirectory = "/home/${me.nickname}";
    packages = with pkgs; [
      file
      unzip
      zip

      dig
      mtr

      signal-desktop

      dconf
      pipewire

      localsend
      blueberry
      qbittorrent
      keepassxc
      yubico-piv-tool

      libreoffice-qt6

      inputs.flurry.packages.${system}.flurry
      inputs.tsunami.packages.${system}.tsunami
    ];
    pointerCursor = {
      gtk.enable = true;
      name = cursor_name;
      size = 32;
      package = pkgs.runCommandNoCC "${cursor_name}" { } ''
        mkdir -p $out/share/icons
        ln -s ${cursor_src} $out/share/icons/${cursor_name}
      '';
    };
    preferXdgDirectories = true;
    sessionVariables = {
      EDITOR = "nvim";
      TERM = "kitty";
      GDK_BACKEND = "wayland,x11";
      QT_QPA_PLATFORM = "wayland;xcb";
      CLUTTER_BACKEND = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      WLR_NO_HARDWARE_CURSORS = "1";
    };
    stateVersion = "23.11"; # Do not change :3
    username = me.nickname;
  };

  nixpkgs.config.allowUnfree = true;

  modules = {
    hyprland = {
      enable = true;
      displays = [
        {
          name = "DP-3";
          horizontal = 2560;
          vertical = 1440;
          horizontal-offset = 2560;
          vertical-offset = 0;
          refresh-rate = 360;
          scale = "1";
        }
        {
          name = "DP-2";
          horizontal = 2560;
          vertical = 1440;
          horizontal-offset = 0;
          vertical-offset = 0;
          refresh-rate = 144;
          scale = "1";
        }
      ];
    };
    games.enable = true;
    apps = {
      enable = true;
      git = {
        name = me.fullName;
        email = me.email;
        do_sign = true;
      };
      thunderbird = {
        enable = true;
      };
      neovim.enableLanguages = true;
    };
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;
    gtk2.extraConfig = ''
      gtk-enable-animations=1
      gtk-primary-button-warps-slider=1
      gtk-toolbar-style=3
      gtk-menu-images=1
      gtk-button-images=1
      gtk-sound-theme-name="ocean"
      gtk-font-name="Noto Sans,  10"
    '';
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  programs = {
    btop = {
      enable = true;
      settings = {
        color_theme = "ayu";
        theme_background = false;
        truecolor = true;
        vim_keys = true;
        rounded_corners = true;
        update_ms = 500;
        proc_mem_bytes = true;
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    # FIX: gpg should be declarative, but is more work than I have time for rn
    gpg = {
      enable = false;
    };
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # add `play funny video` as alias because why not
    zsh.shellAliases.bzzt = ''nix-shell -p mpv --command "mpv ~/Videos/BZZZM.mp4"'';
    # lsd makes files look better
    lsd = {
      enable = true;
      enableAliases = true;
    };
    # manpages can be quite useful
    man.enable = true;
    obs-studio.enable = true;
    ssh = {
      enable = true;
      compression = true;
      matchBlocks = {
        "aur" = {
          host = "aur.archlinux.org";
          hostname = "aur.archlinux.org";
          addressFamily = "any";
          identityFile = "~/.ssh/aur";
          identitiesOnly = true;
          port = 22;
          user = "aur";
        };
        "nuos" = {
          host = "nuos";
          hostname = "nuos";
          addressFamily = "inet";
          identityFile = "~/.ssh/id_rsa_yubikey.pub";
          identitiesOnly = true;
          port = 22;
          user = "noa";
        };
        "github" = {
          host = "github.com";
          hostname = "github.com";
          identityFile = "~/.ssh/id_rsa_yubikey.pub";
          identitiesOnly = true;
          port = 22;
          user = "git";
        };
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  services = {
    syncthing = {
      enable = true;
      tray.enable = true;
    };
    gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      enableSshSupport = true;
      enableScDaemon = true;
      pinentryPackage = pkgs.pinentry-qt;
    };
  };

}
