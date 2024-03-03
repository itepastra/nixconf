{ config, pkgs, inputs, ... }:

{
	imports =
	[
		inputs.nixvim.homeManagerModules.nixvim
		../../common/zsh.nix
		../../common/hyprland.nix
		../../common/git.nix
		../../common/nvim/nvim.nix
		../../common/discord/discord.nix
		../../common/spotify.nix
		../../common/automapaper/automapaper.nix
		../../common/firefox.nix
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

		obs-studio

		btop

		dconf
		pipewire
		lsd

		# Programming langs
		go
		nodejs

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

	xdg = {
		enable = true;
	};

	xdg.userDirs = {
		enable = true;
		createDirectories = true;
	};

	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
		configPackages = [ pkgs.hyprland ];
	};

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

	home.pointerCursor = 
		let 
			getFrom = url: hash: name: {
				gtk.enable = true;
				x11.enable = true;
				name = name;
				size = 32;
				package = 
					pkgs.runCommand "moveUp" {} ''
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
