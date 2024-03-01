{ config, pkgs, inputs, ... }:

{
	imports =
	[
		inputs.nixvim.homeManagerModules.nixvim
		../../common/wofi.nix
		../../common/zsh.nix
		../../common/hyprland.nix
		../../common/waybar.nix
		../../common/git.nix
		../../common/nvim/nvim.nix
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
		(symlinkJoin {
			name = "spotify";
			paths = [
				(writeShellScriptBin "spotify" ''  
		exec ${spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
				'')
				spotify
			];
		})

		hyprland
		dunst
		waybar
		wl-clipboard

		dconf
		(symlinkJoin {
			name = "discord";
			paths = [
				(writeShellScriptBin "discord" ''  
		exec ${discord}/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland
				'')
				(writeShellScriptBin "Discord" ''  
		exec ${discord}/bin/Discord --enable-features=UseOzonePlatform --ozone-platform=wayland
				'')
				discord
			];
		})
		kitty
		pipewire
		lsd
		neovim
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
}
