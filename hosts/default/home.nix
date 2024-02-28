{ config, pkgs, inputs, ... }:

{
  imports =
  [
      inputs.nixvim.homeManagerModules.nixvim
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

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
		pkgs.file
		pkgs.unzip
		pkgs.zip

		pkgs.dig
		pkgs.mtr

		pkgs.firefox
		(pkgs.writeShellScriptBin "spotify" ''
					exec ${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
			'')

		pkgs.hyprland
		pkgs.dunst
		pkgs.waybar

		(pkgs.writeShellScriptBin "discord" ''
					exec ${pkgs.discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland
			'')
		pkgs.kitty
		pkgs.wofi
		pkgs.pipewire
		pkgs.lsd
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
  };

  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # TODO move to seperate file
  programs.zsh = {
		enable=true;
		shellAliases = {
			ll = "lsd -l";
			update = "sudo nixos-rebuild switch --flake /etc/nixos#default";
		};
		history = {
			path = "${config.xdg.dataHome}/zsh/history";
			size = 10000;
		};
		oh-my-zsh = {
			enable = true;
			plugins = [ "git" ];
			theme = "frisk";
		};
  };

	programs.kitty = {
		enable = true;
		settings = {
			confirm_os_window_close = 0;
		};
		shellIntegration.enableZshIntegration = true;
	};

	programs.waybar = {
		enable = true;
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 28;
				output = [
					"DP-3"
					"DP-2"
				];
				modules-left = [ "hyprland/workspaces" "tray" "custom/pronouns" "custom/spotify" ];
				modules-center = [ "hyprland/window" "clock" ];
				modules-right = [ "custom/vpn" "wireplumber" "network" "cpu" "memory" "keyboard-state" "custom/poweroff" ];
				"clock" = {
					tooltip-format = "<big>{:%Y %B}</big>\n\n<small>{calendar}</small>";
					interval = 1;
					format = "{:%H:%M:%S}";
					format-alt = ":%Y-%m-%d %H:%M:%S}";
					on-click-middle = "gnome-clocks";
					calendar = {
						weeks-pos = "left";
						format = {
							today = "<span color='#FF6666'><u>{}</u></span>";
							weeks = "<span color='#707A8C'>{}</span>";
						};
					};
				};
				"tray".spacing = 10;
				"cpu" = {
					format = "cpu: {usage}%";
					tooltip = false;
				};
				"memory" = {
					format = "mem: {}%";
				};
				"wireplumber" = {
					format = "{volume}%";
				};
				"custom/vpn" = {
					format = "VPN";
					exec = "echo '{\"class\": \"connected\"}'";
					exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
					return-type = "json";
					interval = 5;
				};
				"custom/poweroff" = {
					# TODO fix format 
					format = "P";
					# TODO make this file exist
					on-click = "bash ${config.xdg.configHome}/wofi/powermenu.sh";
					on-click-right = "bash ${config.xdg.configHome}/wofi/powermenu.sh";
				};
				"custom/pronouns" = {
					format = "{}";
					exec = "${config.xdg.configHome}/waybar/pronouns";
					interval = 5;
				};
				"hyprland/workspaces" = {
					format = "{name}";
					on-click = "activate";
					sort-by = "id";
				};
			};
		};
		style = ../../styles/waybar.css;
	};

  # TODO extend and move to seperate file
  programs.git = {
		enable = true;
		userName = "Noa Aarts";
		userEmail = "itepastra@gmail.com";
		extraConfig = {
			init = { defaultBranch = "main"; };
			safe.directory = "/etc/nixos";
		};
  };

  # TODO move to seperate file
  # TODO create neovim config
  programs.nixvim = {
  	enable = true;
    vimAlias = true;

    # Configure neovim options...
    options = {
      relativenumber = true;
      incsearch = true;
    };

    # ...mappings...
    keymaps = [
    	{
		mode = "n";
		key = "<C-s>";
		action = ":w<CR>";
	}
	{
		mode = "n";
		key = "<esc>";
		action = ":noh<CR>";
		options.silent = true;
	}
	{
		mode = "v";
		key = ">";
		action = ">gv";
	}
	{
		mode = "v";
		key = "<";
		action = "<gv";
	}
    ];

    plugins = {
      telescope.enable = true;

      lsp = {
        keymaps = {
          silent = true;
          diagnostic = {
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            K = "hover";
          };
        };
        servers = {
          bashls.enable = true;
          clangd.enable = true;
          nil_ls.enable = true;
        };
      };
    };

    # ... and even highlights and autocommands !
    highlight.ExtraWhitespace.bg = "red";
    match.ExtraWhitespace = "\\s\\+$";
    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2";
      }
    ];
  };

  # TODO move to seperate file
  wayland.windowManager.hyprland = {
  	enable = true;
	settings = {
		monitor = [
			"DP-3,2560x1440@144,1920x0,1"
			"DP-2,1920x1080@60,0x0,1"
		];
		windowrulev2 = [
			"opacity 0.8 0.8,class:^(kitty)$"
			"stayfocused,class:^(wofi)$"
		];
		env = [
			"WLR_NO_HARDWARE_CURSORS,1"
		];
		exec-once = [
			"waybar"
			"dunst"
		];
		general = {
			sensitivity = "1.2";
			gaps_in = "2";
			gaps_out = "3";
			border_size = "3";
			"col.active_border"="0xff7c94bf";
			"col.inactive_border"="0x00ffffff";
		};
		decoration = {
			rounding = "6";
			active_opacity = "1";
			inactive_opacity = "1";
		};
		workspace = [
			"DP-3,1"
			"DP-2,2"
		];
		animations = {
			enabled = "1";
			animation = [
				"windows,1,2,default"
				"border,1,10,default"
				"fade,0,5,default"
				"workspaces,1,4,default"
			];
		};
		"$mod" = "SUPER";
		bind = [
			"$mod,Return,exec,kitty"
			"$mod,tab,cyclenext"
			"SUPERSHIFT,Q,killactive"
			"$mod,SPACE,exec,bash ${config.xdg.configHome}/wofi/launcher.sh"
			"$mod,P,exec,bash ${config.xdg.configHome}/wofi/powermenu.sh"
			"SUPERSHIFT,m,exit"
			"$mod,H,movefocus,l"
			"$mod,J,movefocus,u"
			"$mod,K,movefocus,d"
			"$mod,L,movefocus,r"
			"SUPERSHIFT,H,movefocus,l"
			"SUPERSHIFT,J,movefocus,u"
			"SUPERSHIFT,K,movefocus,d"
			"SUPERSHIFT,L,movefocus,r"
			"$mod,F,togglefloating"
			"$mod,X,togglespecialworkspace"
			"SUPERSHIFT,X,movetoworkspace,special"
			"$mod,Print,exec,grim - | wl-copy && notify-send 'Screenshot Copied to Clipboard'"
			"SUPERSHIFT,S,exec,slurp | grim -g - /tmp/photo && wl-copy < /tmp/photo && notify-send 'Screenshot Copied to Clipboard'"
			"$mod,f11,fullscreen,0"
			",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_SINK@ 1%-"
			",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_SINK@ 1%+"
			",XF86AudioMute,exec,wpctl set-mute @DEFAULT_SINK@ toggle"
			",XF86AudioPlay,exec,playerctl play-pause"
			",XF86AudioPrev,exec,playerctl previous"
			",XF86AudioNext,exec,playerctl next"
			]
		++ (
			builtins.concatLists (builtins.genList (
				x: let
					ws = let
						c = (x+1);
					in
						builtins.toString (x);
				in [
					"$mod,${ws},workspace,${ws}"
					"ALT,${ws},movetoworkspace,${ws}"
				]
			)
			10)
		);
		bindm = [
			"$mod,mouse:272,movewindow"
			"$mod,mouse:273,resizewindow"
		];
	};
  };

}
