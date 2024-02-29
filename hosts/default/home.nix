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
	home.packages = with pkgs; [
		file
		unzip
		zip

		dig
		mtr

		firefox
		# (writeShellScriptBin "spotify" ''
		# 		exec ${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
		# 	'')
		spotify

		hyprland
		dunst
		waybar
		wl-clipboard

		dconf

		# (writeShellScriptBin "discord" ''
		# 		exec ${discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland
		# 	'')
		discord
		kitty
		pipewire
		lsd
		(writeShellScriptBin "wofi-launch" ''
				${wofi}/bin/wofi --show drun
			'')
		(writeShellScriptBin "wofi-power" ''
				lock="Lock"
				logout="Logout"
				poweroff="Poweroff"
				reboot="Reboot"
				sleep="Suspend"
				
				selected_option=$(echo -e "$lock\n$logout\n$sleep\n$reboot\n$poweroff" | wofi --dmenu -i -p "Powermenu")

				if [ "$selected_option" == "$lock" ]
				then
					echo "lock"
					swaylock
				elif [ "$selected_option" == "$logout" ]
				then
					echo "logout"
					loginctl terminate-user `whoami`
				elif [ "$selected_option" == "$poweroff" ]
				then
					echo "poweroff"
					poweroff
				elif [ "$selected_option" == "$reboot" ]
				then
					echo "reboot"
					reboot
				elif [ "$selected_option" == "$sleep" ]
				then
					echo "sleep"
					suspend
				else
					echo "No match"
				fi
			'')
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
		#	 org.gradle.console=verbose
		#	 org.gradle.daemon.idletimeout=3600000
		# '';
	};

	# Home Manager can also manage your environment variables through
	# 'home.sessionVariables'. If you don't want to manage your shell through Home
	# Manager then you have to manually source 'hm-session-vars.sh' located at
	# either
	#
	#	~/.nix-profile/etc/profile.d/hm-session-vars.sh
	#
	# or
	#
	#	~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
	#
	# or
	#
	#	/etc/profiles/per-user/noa/etc/profile.d/hm-session-vars.sh
	#
	home.sessionVariables = {
		EDITOR = "nvim";
		TERM = "kitty";
	};

	xdg.userDirs.enable = true;
	xdg.userDirs.createDirectories = true;

	dconf = {
		enable = true;
		settings = {
			"org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
			};
		};
	};

	# Let Home Manager install and manage itself.
	programs.home-manager.enable = true;

	# TODO move to seperate file
	programs.wofi = {
		enable = true;
		settings = {
		
		};
		style = ''
			* {
				outline: none;
				outline-style: none;
			}

			#window {
				margin: 10px;
				border: none;
				background-color: #530035;
				border-radius: 10px;
				font-family:
					JetBrains Mono NF,
					monospace;
				font-weight: bold;
				font-size: 14px;
			}

			#outer-box {
				margin: 10px;
				border: 2px @lavender;
				border-radius: 10px;
				background-color: transparent;
			}

			#input {
				border: none;
				border-radius: 10px;
				margin-left: 2px;
				color: @text;
				outline-style: none;
				background-color: @base;
			}

			#scroll {
				border: 10px solid @mantle;
				border-radius: 10px;
				/*padding-right: 10px;*/
				outline: none;
				background-color: @base;
			}

			#inner-box {
				border: none;
				border-radius: 10px;
				background-color: transparent;
			}

			#entry {
				border: none;
				/*border-radius: 10px;
					margin-right: 15px;
					margin-left: 15px;*/
				padding-right: 10px;
				padding-left: 10px;
				color: @subtext0;
				background-color: @base;
			}
			#entry:selected {
				border: none;
				background-color: @green;
			}

			#text:selected {
				border: none;
				color: @crust;
			}

			#img {
				background-color: transparent;
				margin-right: 6px;
			}
		'';
	};

	# TODO move to seperate file
	programs.zsh = {
		enable=true;
		shellAliases = {
			ll = "lsd -l";
			lt = "lsd -l --tree";
			update = "sudo nixos-rebuild switch --flake $HOME/nixos#default";
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
					on-click = "wofi-power";
					on-click-right = "swaylock";
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
	programs.nixvim = {
		enable = true;
		vimAlias = true;
		globals = {
			mapleader = " ";
			maplocalleader = " ";
		};

		colorschemes.catppuccin.enable = true;

		# Configure neovim options...
		options = {
			tabstop = 4;
			shiftwidth = 4;
			relativenumber = true;
			incsearch = true;
			hlsearch = true;
			number = true;
			mouse = "a";
			showmode = false;
			breakindent = true;
			undofile = true;
			ignorecase = true;
			smartcase = true;
			signcolumn = "yes";
			updatetime = 250;
			timeoutlen = 300;
			splitright = true;
			splitbelow = true;
			list = true;
			listchars = {
				tab = "> ";
				trail = ".";
				nbsp = "_";
			};
			inccommand = "nosplit";
			cursorline = true;
			scrolloff = 8;
		};

		# ...mappings...
		keymaps = [
			{
				mode = "n";
				key = "<Esc>";
				action = "<cmd>nohlsearch<CR>";
				options.desc = "Remove search highlights";
			}
			{
				mode = "t";
				key = "<Esc><Esc>";
				action = "<C-\\><C-n>";
				options.desc = "Exit terminal mode";
			}
			{
				mode = "n";
				key = "<C-h>";
				action = "<C-w><C-h>";
				options.desc = "Move focus to the left window";
			}
			{
				mode = "n";
				key = "<C-l>";
				action = "<C-w><C-l>";
				options.desc = "Move focus to the right window";
			}
			{
				mode = "n";
				key = "<C-j>";
				action = "<C-w><C-j>";
				options.desc = "Move focus to the lower window";
			}
			{
				mode = "n";
				key = "<C-k>";
				action = "<C-w><C-k>";
				options.desc = "Move focus to the upper window";
			}
			{
				mode = "n";
				key = "<leader>pv";
				lua = true;
				action = "vim.cmd.Ex";
				options.desc = "Open the integrated file explorer";
			}
			{
				mode = "x";
				key = "<leader>p";
				action = "[[\"_dP]]";
				options.desc = "Paste but not override";
			}
			{
				mode = [
					"n"
					"v"
				];
				key = "<leader>d";
				action = ''[["_d]]'';
				options.desc = "Delete no without copying";
			}
			{
				mode = [
					"n"
					"v"
				];
				key = "<leader>y";
				action = ''[["+y]]'';
				options.desc = "Copy to system clipboard";
			}
			{
				mode = "n";
				key = "<leader>Y";
				action = ''[["+Y]]'';
				# TODO find out what this remap does
				options.desc = "IDK";
			}
			{
				mode = "v";
				key = "J";
				action = ":m '>+1<CR>gv=gv";
				options.desc = "Move selected lines down";
			}
			{
				mode = "v";
				key = "K";
				action = ":m '<-2<CR>gv=gv";
				options.desc = "Move selected lines up";
			}
		];

		plugins = {
			fugitive.enable = true;
			comment-nvim.enable = true;
			nvim-colorizer.enable = true;
			telescope = {
				enable = true;
				keymaps = {
					"<leader>sh" = {
						action = "help_tags";
						desc = "[S]earch [H]elp";
					};
					"<leader>sk" = {
						action = "keymaps";
						desc = "[S]earch [K]eymaps";
					};
					"<leader>sf" = {
						action = "find_files";
						desc = "[S]earch [F]iles";
					};
					"<leader>ss" = {
						action = "builtin";
						desc = "[S]earch [S]elect Telescope";
					};
					"<leader>sw" = {
						action = "grep_string";
						desc = "[S]earch current [W]ord";
					};
					"<leader>sg" = {
						action = "live_grep";
						desc = "[S]earch by [G]rep";
					};
					"<leader>sd" = {
						action = "diagnostics";
						desc = "[S]earch [D]iagnostics";
					};
					"<leader>sr" = {
						action = "resume";
						desc = "[S]earch [R]esume";
					};
					"<leader>s." = {
						action = "oldfiles";
						desc = "[S]earch recent files (\".\" for repeat)";
					};
					"<leader><leader>" = {
						action = "buffers";
						desc = "[ ] Find existing buffers";
					};
				};
			};
			treesitter = {
				enable = true;
				indent = true;
			};
			lsp = {
				enable = true;
				enabledServers = [
					"lua_ls"
				];
				keymaps = {
					silent = true;
					diagnostic = {
						"[d" = {
							action = "goto_prev";
							desc = "Go to previous [D]iagnostic message";
						};
						"]d" = {
							action = "goto_next";
							desc = "Go to next [D]iagnostic message";
						};
						"<leader>e" = {
							action = "open_float";
							desc = "Show diagnostic [E]rror messages";
						};
						"<leader>q" = {
							action = "setloclist";
							desc = "Open diagnostic [Q]uickfix list";
						};
					};
				};
			};
			gitsigns = {
				enable = true;
				signs = {
					add = { text = "+"; };
					change = { text = "~"; };
					delete = { text = "_"; };
					topdelete = { text = "T"; };
					changedelete = { text = "~"; };
				};
			};
		};
		match.ExtraWhitespace = "\\s\\+$";
		autoCmd = [
			{
				event = "FileType";
				pattern = "nix";
				command = "setlocal tabstop=2 shiftwidth=2";
			}
			{
				event = "LspAttach";
				callback = ''
					function (event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
				'';
			}
		];
		extraPlugins = with pkgs.vimPlugins; [
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
			"$mod,SPACE,exec,wofi-launch"
			"$mod,P,exec,wofi-power"
			"SUPERSHIFT,m,exit"
			"$mod,H,movefocus,l"
			"$mod,J,movefocus,u"
			"$mod,K,movefocus,d"
			"$mod,L,movefocus,r"
			"SUPERSHIFT,H,movewindow,l"
			"SUPERSHIFT,J,movewindow,u"
			"SUPERSHIFT,K,movewindow,d"
			"SUPERSHIFT,L,movewindow,r"
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
