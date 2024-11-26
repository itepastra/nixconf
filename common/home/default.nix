# I make a function that takes some settings and then returns a home module....
{
  # if I have a monitor and want niri + graphical apps
  enableGraphical ? false,
  # should add flurry and tsunami?? (yes :3)
  enableFlut ? false,
  # GAMESS, like for things like steam and minecraft
  enableGames ? false,
  # what displays are connected? automapaper and niri will be configured using this
  displays ? [ ],
  # is there any extra specific config necessary (like nvidia on lambdaOS)
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
  # woah, it's stuff about me, pls no doxxing thnx
  me = {
    nickname = "noa";
    fullName = "Noa Aarts";
    email = "noa@voorwaarts.nl";
  };

  # I like my animated rainbow cursor, so I get it here
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
      # I made some cursed modules (waybar is the worst)
      ../../modules
      # Was too lazy to do fully declarative nvim, so the lua is hidden there as well
      ../nvim/nvim.nix
      # we import extraConfig, it's funny that this has the correct effect
      extraConfig
    ]
    # these have no use if there isn't any display....
    ++ lib.optionals enableGraphical [
      ../discord/discord.nix
      ../spotify.nix
    ];

  home = {
    file = {
      # makes yubikey stuff work
      ".gnupg/scdaemon.conf".text = "disable-ccid";
      # I don't want the directory directly in home, even though I only go to it via the symlink
      "programming".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/programming/";
    };
    # haha, now I can set my home folder like this
    homeDirectory = "/home/${me.nickname}";
    # most actual packages are added via either programs or services...
    packages =
      with pkgs;
      [
        # file things
        file
        unzip
        zip

        #network things
        dig
        mtr
      ]
      # FLURRY AND TSUNAMI :3 (I made these)
      ++ lib.optionals enableFlut [
        inputs.flurry.packages.${system}.flurry
        inputs.tsunami.packages.${system}.tsunami
      ]
      # and ofc the things that are only logical with graphics
      ++ lib.optionals enableGraphical [
        #comminucation things
        signal-desktop

        # service things
        dconf
        pipewire
        wl-clipboard
        libnotify
        playerctl

        # apps 
        localsend
        blueberry
        qbittorrent
        keepassxc
        yubico-piv-tool
        libreoffice-qt6
      ];

    # I set my cursor here, the one I fetched above
    pointerCursor = lib.mkIf enableGraphical {
      gtk.enable = true;
      name = cursor_name;
      size = 32;
      package = pkgs.runCommandNoCC "${cursor_name}" { } ''
        mkdir -p $out/share/icons
        ln -s ${cursor_src} $out/share/icons/${cursor_name}
      '';
    };
    # make stuff use .config etc (ask nicely at least)
    preferXdgDirectories = true;

    # I'm unsure if these work, which is annoying, but eh. who cares
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

    # the default config told me not to change this
    stateVersion = "23.11"; # WARN: Do not change :3

    # I can also use me here, wowa
    username = me.nickname;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      configPackages = [ pkgs.niri ];
    };
    # If I have a monitor I want niri with my config, but niri wants it at that spot
    configFile = lib.mkIf enableGraphical {
      "niri/config.kdl".source = import ../../packages/niri-config/default.nix {
        inherit pkgs inputs displays;
        self-pkgs = inputs.self.packages.${pkgs.system};
      };
    };
  };

  # Needed for like spotify or something
  nixpkgs.config.allowUnfree = true;

  modules = {
    # imagine steam but like without a monitor
    games.enable = enableGraphical && enableGames;

    # other things I like to use
    apps = {
      #my terminal language of choice
      zsh.enable = true;
      # some browser if I have a screen
      firefox.enable = enableGraphical;
      # terminal emulator...
      kitty.enable = enableGraphical;
      # git settings
      # TODO: add the one that sets upstream branches on it's own
      git = {
        enable = true;
        name = me.fullName;
        email = me.email;
        do_sign = true;
      };
      # mail stuffs
      thunderbird.enable = enableGraphical;
      # this just makes neovim function, or does it not matter anymore??
      # TODO: check if this is needed
      neovim.enableLanguages = true;
    };
    # my very cursed module for waybar is activated here
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
  };

  systemd.user = {
    # since all these services are for programs in niri so far, I just enable all of them if I have screen.
    enable = enableGraphical;
    # makes them restart with smart or something?
    startServices = "sd-switch";

    services = lib.mkMerge [
      {
        spotify =
          let
            spotify = (
              pkgs.writeShellScriptBin "spotify" ''${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland''
            );
          in
          {
            Install = {
              WantedBy = [ "niri.service" ];
            };

            Unit = {
              PartOf = "graphical-session.target";
              After = "graphical-session.target";
              Requisite = "graphical-session.target";
            };

            Service = {
              ExecStart = "${spotify}/bin/spotify";
              Type = "exec";
              RestartSec = 15;
            };
          };

        mako = {
          Install = {
            WantedBy = [ "niri.service" ];
          };

          Unit = {
            PartOf = "graphical-session.target";
            After = "graphical-session.target";
            Requisite = "graphical-session.target";
          };

          Service = {
            ExecStart = "${pkgs.mako}/bin/mako";
            Type = "exec";
            Restart = "on-failure";
            RestartSec = 15;
          };
        };

        xwayland = {
          Install = {
            WantedBy = [ "niri.service" ];
          };

          Unit = {
            PartOf = "graphical-session.target";
            After = "graphical-session.target";
            Requisite = "graphical-session.target";
          };

          Service = {
            ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
            Type = "exec";
            Restart = "on-failure";
            RestartSec = 15;
          };
        };

        waybar = {
          Service.RestartSec = 5;
        };
      }
      # makes an automapaper service and config for every monitor.
      (builtins.listToAttrs (
        builtins.map (
          {
            name,
            horizontal,
            vertical,
            ...
          }:
          let
            display_config =
              let
                display-shader = pkgs.substituteAll {
                  src = ../../modules/automapaper/display-with_vars.glsl;
                  background = inputs.nix-colors.lib.conversions.hexToGLSLVec "0a000a";
                  foreground = inputs.nix-colors.lib.conversions.hexToGLSLVec "192291";
                };
                state-shader = ../../modules/automapaper/state-game_of_life.glsl;
                init-shader = ../../modules/automapaper/init.glsl;
                # General configurations
                cycles = 2000;
                tps = 30;
                horizontal-dot-size = 10;
                vertical-dot-size = 10;
              in
              (import ../../modules/automapaper/config.nix {
                inherit (pkgs) writeTextFile;
                inherit
                  init-shader
                  state-shader
                  display-shader
                  tps
                  cycles
                  ;
                display = name;
                horizontal = builtins.div horizontal horizontal-dot-size;
                vertical = builtins.div vertical vertical-dot-size;
              });

          in
          lib.attrsets.nameValuePair "automapaper-${name}" ({
            Install = {
              WantedBy = [ "niri.service" ];
            };
            Unit = {
              Description = "Automapaper for display ${name}";
              PartOf = "graphical-session.target";
              After = "graphical-session.target";
              Requisite = "graphical-session.target";
            };

            Service = {
              ExecStart = "${
                inputs.automapaper.packages.${pkgs.system}.automapaper
              }/bin/automapaper -C ${display_config}/config.toml";
              Restart = "on-failure";
              RestartSec = 15;
            };
          })
        ) displays
      ))
    ];
  };

  # bae xdg makes some standards etc.
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  #attempt at styling...., mostly just trying to not get flashbanged
  dconf = {
    enable = enableGraphical;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  # same here
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
    # wowa, I can set btop settings from here???
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
    # does devshells using flakes. Very nice since it just works
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      config.global = {
        load_dotenv = true;
        log_format = "-";
        hide_env_diff = true;
      };
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
    # even though I don't really record, I still want to be able to quickly
    obs-studio.enable = enableGraphical;
    # ssh, my big friend. WHY do you do difficult sometimes
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

  # and MORE styling options and settings
  qt = {
    enable = enableGraphical;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  services = {
    # to make my yubikey and git signing do things correctly
    gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      enableSshSupport = true;
      pinentryPackage = lib.mkIf enableGraphical pkgs.pinentry-qt;
    };
    # notification daemon, I think it looks better than dunst
    mako = {
      enable = true;
      backgroundColor = "#000000AA";
      # make notifications time out after 30 sec by default
      defaultTimeout = 30000;
      borderColor = "#${config.colorScheme.palette.base00}FF";
    };
    playerctld.enable = true;
    swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 300;
          command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
          resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
        }
      ];
    };
    # sync my password store and homework
    syncthing = {
      enable = true;
    };
  };
}
