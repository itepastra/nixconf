{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [
      ../../modules/hyprland.nix
      ../../modules/games
      ../../modules/applications
      ../../common/nvim/nvim.nix
      ../../common/discord/discord.nix
      ../../common/spotify.nix
    ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "noa";
  home.homeDirectory = "/home/noa";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  modules = {
    hyprland.enable = true;
    games.enable = true;
    apps = {
      enable = true;
      git = {
        name = "Noa Aarts";
        email = "noa@voorwaarts.nl";
        do_sign = true;
      };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    file
    unzip
    zip

    dig
    mtr

    obs-studio
    wayvnc

    signal-desktop

    btop

    dconf
    pipewire
    lsd

    localsend
    blueberry
    qbittorrent
    planify
    keepassxc
    yubikey-manager-qt
    yubico-piv-tool
  ];


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    "ykcs/ykcs11.so".source = "${pkgs.yubico-piv-tool}/lib/libykcs11.so";
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/noa/etc/profile.d/hm-session-vars.sh
  #


  home.sessionVariables = {
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

  # Let Home Manager install and manage itself.
  programs = {
    home-manager = {
      enable = true;
      backupFileExtension = "backup";
    };
    zsh.shellAliases.bzzt = ''nix-shell -p mpv --command "mpv ~/Videos/BZZZM.mp4"'';
  };

  home.pointerCursor =
    let
      getFrom = url: hash: name: {
        gtk.enable = true;
        x11.enable = true;
        name = name;
        size = 32;
        package =
          pkgs.runCommand "moveUp" { } ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.fetchzip {
              url = url;
              hash = hash;
            }} $out/share/icons/${name}
          '';
      };
    in
    getFrom
      "https://github.com/ful1e5/Bibata_Cursor_Rainbow/releases/download/v1.1.2/Bibata-Rainbow-Modern.tar.gz"
      "sha256-Ps+IKPwQoRwO9Mqxwc/1nHhdBT2R25IoeHLKe48uHB8="
      "Bibata-Rainbow-Modern";
}
