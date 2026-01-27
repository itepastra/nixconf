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
  cursor_src = pkgs.runCommand cursor_name { } ''
    mkdir -p $out/share/icons
    ln -s ${
      pkgs.fetchzip {
        name = cursor_name;
        url = "https://github.com/ful1e5/Bibata_Cursor_Rainbow/releases/download/v1.1.2/${cursor_name}.tar.gz";
        hash = "sha256-Ps+IKPwQoRwO9Mqxwc/1nHhdBT2R25IoeHLKe48uHB8=";
      }
    } $out/share/icons/${cursor_name}
  '';
in
{
  imports = [
    # I made some cursed modules (waybar is the worst)
    ../../modules
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
      ".ssh/id_rsa_yubikey.pub".text = builtins.elemAt (import ../ssh-keys.nix) 0;
      # I don't want the directory directly in home, even though I only go to it via the symlink
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
        inputs.flurry.packages.${stdenv.hostPlatform.system}.default
        inputs.tsunami.packages.${stdenv.hostPlatform.system}.default
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
        libreoffice
        tmux

        krita
      ];

    # # I set my cursor here, the one I fetched above
    # pointerCursor = lib.mkIf enableGraphical {
    #   gtk.enable = true;
    #   name = cursor_name;
    #   size = 32;
    #   package = pkgs.runCommandNoCC "${cursor_name}" { } ''
    #     mkdir -p $out/share/icons
    #     ln -s ${cursor_src} $out/share/icons/${cursor_name}
    #   '';
    # };
    # make stuff use .config etc (ask nicely at least)
    preferXdgDirectories = true;

    # I'm unsure if these work, which is annoying, but eh. who cares
    sessionVariables = {
      EDITOR = "nvim";
      TERM = "kitty";
    };

    # the default config told me not to change this
    stateVersion = "26.05"; # WARN: Do not change :3

    # I can also use me here, wowa
    username = me.nickname;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      configPackages = [ pkgs.niri ];
    };

    mime = {
      enable = true;
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/pdf" = "firefox.desktop";
      };
    };
    # If I have a monitor I want niri with my config, but niri wants it at that spot
    configFile = {
      "mimeapps.list".force = true;
    }
    // lib.mkIf enableGraphical {
      "niri/config.kdl".source = import ../../packages/niri-config/default.nix {
        inherit pkgs displays;
        inputs = inputs;
        self-pkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
      };
    };
  };

  # Needed for like spotify or something
  nixpkgs.config.allowUnfree = true;

  modules = {
    # imagine steam but like without a monitor
    games.enable = enableGraphical && enableGames;
    games.lutris.enable = false;

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
    };
    # my very cursed module for waybar is activated here
    waybar = {
      modules = {
        left = [
          "niri/workspaces"
          "niri/window"
        ];
        center = [
          "clock"
          "custom/spotify"
        ];
        right = [
          "battery"
          "custom/bluetooth"
          "network"
          "wireplumber"
          "cpu"
          "memory"
          "temperature"
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
              pkgs.writeShellScriptBin "spotify" "${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland"
            );
          in
          {
            Install = {
              WantedBy = [ "niri.service" ];
            };

            Unit = {
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

        swayidle = {
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
                hexToGLSLVec =
                  color:
                  let
                    cs = config.lib.stylix.colors;
                    red = cs."${color}-dec-r";
                    green = cs."${color}-dec-g";
                    blue = cs."${color}-dec-b";
                  in
                  "vec4(${red}, ${green}, ${blue}, 1.0);";
                display-shader = pkgs.replaceVars ../../modules/automapaper/display-with_vars.glsl {
                  background = hexToGLSLVec "base00";
                  foreground = hexToGLSLVec "base0E";
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
              After = "graphical-session.target";
              Requisite = "graphical-session.target";
            };

            Service = {
              ExecStart = "${
                inputs.automapaper.packages.${pkgs.stdenv.hostPlatform.system}.automapaper
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
  dconf.enable = enableGraphical;

  # same here
  gtk = {
    enable = lib.mkForce enableGraphical;
    gtk2 = {
      extraConfig = ''
        gtk-enable-animations=1
        gtk-primary-button-warps-slider=1
        gtk-toolbar-style=3
        gtk-menu-images=1
        gtk-button-images=1
        gtk-sound-theme-name="ocean"
        gtk-font-name="Noto Sans, 10"
      '';
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
    };
  };

  programs = {
    # chromium = {
    #   enable = enableGraphical;
    #   package = pkgs.ungoogled-chromium;
    # };
    # wowa, I can set btop settings from here???
    btop = {
      enable = true;
      settings = {
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
    fuzzel = {
      enable = true;
      settings = {
        main = {
          line-height = 25;
          fields = "name,generic,comment,categories,filename,keywords";
          terminal = "kitty";
          prompt = "' ➜  '";
          font = "Maple Mono NF";
          layer = "top";
          lines = 10;
          width = 35;
          horizontal-pad = 25;
          inner-pad = 5;
        };
        colors = {
          background = "${config.lib.stylix.colors.base00}aa";
          text = "${config.lib.stylix.colors.base01}bb";
          selection = "${config.lib.stylix.colors.base01}ff";
          selection-match = "${config.lib.stylix.colors.base05}ff";
          border = "${config.lib.stylix.colors.base0E}ee";
        };
        border = {
          radius = 15;
          width = 3;
        };
      };
    };
    # FIX: gpg should be declarative, but is more work than I have time for rn
    gpg = {
      enable = false;
    };
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    hyprlock = {
      enable = enableGraphical;
    };
    # add `play funny video` as alias because why not
    zsh.shellAliases.bzzt = lib.mkIf enableGraphical ''nix-shell -p mpv --command "mpv ~/Videos/BZZZM.mp4"'';
    # lsd makes files look better
    lsd = {
      enable = true;
    };
    # manpages can be quite useful
    man.enable = true;
    # even though I don't really record, I still want to be able to quickly
    obs-studio.enable = enableGraphical;
    # ssh, my big friend. WHY do you do difficult sometimes
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          compression = true;
        };
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

  services = {
    # to make my yubikey and git signing do things correctly
    gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      enableSshSupport = true;
      pinentry.package = lib.mkIf enableGraphical pkgs.pinentry-qt;
    };
    # notification daemon, I think it looks better than dunst
    mako = {
      enable = true;
      # make notifications time out after 30 sec by default
      settings.default-timeout = "30000";
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

  stylix = {
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    cursor = lib.mkIf enableGraphical {
      name = cursor_name;
      package = cursor_src;
      size = 32;
    };
    enable = true;
    polarity = "dark";
    opacity = {
      terminal = 0.2;
      popups = 0.66;
    };
    override = {
      # I liked my background colors from before, make it in more spots
      base00 = "0a000a";
    };
    targets = {
      neovim.enable = false;
      waybar.enable = false;
      fuzzel.enable = false;
      firefox.profileNames = [ "profile_0" ];
      qt = {
        enable = true;
        platform = "qtct";
      };
    };
  };
}
