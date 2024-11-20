{
  enableGraphical ? false,
  enableFlut ? false,
  enableGames ? false,
  displays ? [ ],
  extraConfig ? { },
}:
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
  imports =
    [
      ../modules
      ./nvim/nvim.nix
      extraConfig
    ]
    ++ lib.optionals enableGraphical [
      ./discord/discord.nix
      ./spotify.nix
    ];

  home = {
    file = {
      ".gnupg/scdaemon.conf".text = "disable-ccid";
      "programming".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/programming/";
    };
    homeDirectory = "/home/${me.nickname}";
    packages =
      with pkgs;
      [
        file
        unzip
        zip

        dig
        mtr
      ]
      ++ lib.optionals enableFlut [
        inputs.flurry.packages.${system}.flurry
        inputs.tsunami.packages.${system}.tsunami
      ]
      ++ lib.optionals enableGraphical [
        signal-desktop

        dconf
        pipewire

        localsend
        blueberry
        qbittorrent
        keepassxc
        yubico-piv-tool

        libreoffice-qt6

        # for niri
        wl-clipboard
        libnotify
        playerctl
      ];
    pointerCursor = lib.mkIf enableGraphical {
      gtk.enable = true;
      name = cursor_name;
      size = 32;
      package = pkgs.runCommandNoCC "${cursor_name}" { } ''
        mkdir -p $out/share/icons
        ln -s ${cursor_src} $out/share/icons/${cursor_name}
      '';
    };
    preferXdgDirectories = true;
    sessionVariables =
      {
        EDITOR = "nvim";
        TERM = "kitty";
      }
      // lib.mkIf enableGraphical {
        DISPLAY = ":0";
        GDK_BACKEND = "wayland,x11";
        QT_QPA_PLATFORM = "wayland;xcb";
        CLUTTER_BACKEND = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "niri";
        WLR_NO_HARDWARE_CURSORS = "1";
      };
    stateVersion = "23.11"; # Do not change :3
    username = me.nickname;
  };

  xdg.configFile = lib.mkIf enableGraphical {
    "niri/config.kdl".source = import ../../packages/niri-config/default.nix {
      inherit pkgs inputs displays;
      self-pkgs = inputs.self.packages.${pkgs.system};
    };
  };

  nixpkgs.config.allowUnfree = true;

  modules = {
    waybar = {
      modules = {
        left = [
          "niri/workspaces"
          "tray"
          "niri/window"
        ];
        center = [
          "clock"
          "custom/spotify"
        ];
        right = [
          "custom/vpn"
          "wireplumber"
          "network"
          "cpu"
          "memory"
          "custom/poweroff"
        ];
      };
      enable = lib.mkDefault enableGraphical;
    };
    games.enable = enableGraphical && enableGames;
    apps = {
      zsh.enable = true;
      firefox.enable = enableGraphical;
      kitty.enable = enableGraphical;
      git = {
        enable = true;
        name = me.fullName;
        email = me.email;
        do_sign = true;
      };
      thunderbird.enable = enableGraphical;
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
    enable = enableGraphical;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = enableGraphical;
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
        proc_per_core = true;
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
    zsh.shellAliases.bzzt = lib.mkIf enableGraphical ''nix-shell -p mpv --command "mpv ~/Videos/BZZZM.mp4"'';
    # lsd makes files look better
    lsd = {
      enable = true;
      enableAliases = true;
    };
    # manpages can be quite useful
    man.enable = true;
    obs-studio.enable = enableGraphical;
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
    enable = enableGraphical;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  services = {
    syncthing = {
      enable = true;
    };
    gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      enableSshSupport = true;
      pinentryPackage = lib.mkIf enableGraphical pkgs.pinentry-qt;
    };
  };
}
