# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, nix-colors, ... }:

{
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
			./nvidia.nix
			inputs.home-manager.nixosModules.default
		];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# LOVE me some blob
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

	networking.hostName = "lambdaOS"; # Define your hostname.
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;

	programs.nm-applet.enable = true;

	nix = {
		settings = {
			# auto optimise every so often
			auto-optimise-store = true;
			experimental-features = ["nix-command" "flakes"];
			substituters = ["https://hyprland.cachix.org"];
			trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
		};
		gc.automatic = true;
	};

	# Set your time zone.
	time.timeZone = "Europe/Amsterdam";

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";

	i18n.extraLocaleSettings = {
		LC_ADDRESS = "nl_NL.UTF-8";
		LC_IDENTIFICATION = "nl_NL.UTF-8";
		LC_MEASUREMENT = "nl_NL.UTF-8";
		LC_MONETARY = "nl_NL.UTF-8";
		LC_NAME = "nl_NL.UTF-8";
		LC_NUMERIC = "nl_NL.UTF-8";
		LC_PAPER = "nl_NL.UTF-8";
		LC_TELEPHONE = "nl_NL.UTF-8";
		LC_TIME = "nl_NL.UTF-8";
	};

	services.xserver = {
		enable = true;
		displayManager = {
			sddm.enable = true;
			defaultSession = "hyprland";
		};
		xkb = {
			layout = "us";
			variant = "intl";
		};
	};


	# Configure console keymap
	console.keyMap = "us-acentos";

	users.groups.nixpow.members = [ "root" ];
	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.noa = {
		isNormalUser = true;
		description = "Noa Aarts";
		extraGroups = [ "networkmanager" "wheel" "nixpow" ];
		packages = with pkgs; [
		];
	};

	home-manager = {
		extraSpecialArgs = { 
			inherit inputs; 
			inherit nix-colors;
		};
		users = {
			"noa" = import ./home.nix;
			"root" = import ./root.nix;
		};
	};

	# Allow unfree packages
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		sddm
		git
		zsh
		neovim
	];

	# TODO find list of fonts to install
	fonts.packages = with pkgs; [
		font-awesome
		noto-fonts
		fira-code
		fira-code-symbols
		liberation_ttf
		maple-mono-NF
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };
	programs.zsh.enable = true;
	programs.steam.enable = true;

	programs.hyprland = {
		enable = true;
		portalPackage = pkgs.xdg-desktop-portal-hyprland;
	};

	programs.nix-ld.enable = true;
	programs.nix-ld.libraries = with pkgs; [
		wayland

	];

	users.defaultUserShell = pkgs.zsh;

	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
	};

	boot.kernelModules = [
		"v4l2loopback"
		"nct6775"
		"k10temp"
	];

	boot.extraModprobeConfig = ''
		options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
	'';
	security.polkit.enable = true;

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;

		settings.PasswordAuthentication = false;
		settings.KbdInteractiveAuthentication = false;
	};

	# Open ports in the firewall.
	networking.firewall.allowedTCPPorts = [ 5909 ];
	networking.firewall.allowedUDPPorts = [ 5909 ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "23.11"; # Did you read the comment?
}
