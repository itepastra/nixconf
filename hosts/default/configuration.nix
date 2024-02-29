# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

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

	networking.hostName = "lambdaOS"; # Define your hostname.
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.

	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Enable networking
	networking.networkmanager.enable = true;

	nix = {
		settings = {
			# auto optimise every so often
			auto-optimise-store = true;
			experimental-features = ["nix-command" "flakes"];
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
		extraSpecialArgs = { inherit inputs; };
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
		neovim
		sddm
		git
		zsh
	];

	# TODO find list of fonts to install
	fonts.packages = with pkgs; [
		font-awesome
		noto-fonts
		fira-code
		fira-code-symbols
		liberation_ttf
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };

	programs.neovim.enable = true;
	programs.neovim.defaultEditor = true;

	programs.zsh.enable = true;

	programs.hyprland.enable = true;

	users.defaultUserShell = pkgs.zsh;

	security.rtkit.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
	};


	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	# services.openssh.enable = true;

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
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
