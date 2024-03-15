# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, inputs, nix-colors, ... }:

{
	imports =
	[ # Include the results of the hardware scan.
		./hardware-configuration.nix
		inputs.home-manager.nixosModules.default
	];

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# LOVE me some blob
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

	networking.hostName = "NoasServer"; # Define your hostname.
	# Pick only one of the below networking options.
	# networking.wireless.enable = true;	# Enables wireless support via wpa_supplicant.
	networking.networkmanager.enable = true;	# Easiest to use and most distros use this by default.

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
	# Configure network proxy if necessary
	# networking.proxy.default = "http://user:password@proxy:port/";
	# networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.noa = {
		 isNormalUser = true;
		 extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
		 packages = with pkgs; [
			 firefox
			 tree
		 ];
		 openssh.authorizedKeys.keys = [
				"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINWtje7dGqyrBY7PLq6DANvUR6yfungQNsXGkTO6PP6/ noa@NoasPCArch"
		 ];
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

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };

	# Enable the OpenSSH daemon.
	services.openssh.enable = true;
	programs.zsh.enable = true;

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

	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# Copy the NixOS configuration file and link it from the resulting system
	# (/run/current-system/configuration.nix). This is useful in case you
	# accidentally delete configuration.nix.
	# system.copySystemConfiguration = true;

	# This option defines the first version of NixOS you have installed on this particular machine,
	# and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
	#
	# Most users should NEVER change this value after the initial install, for any reason,
	# even if you've upgraded your system to a new NixOS release.
	#
	# This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
	# so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
	# to actually do that.
	#
	# This value being lower than the current NixOS release does NOT mean your system is
	# out of date, out of support, or vulnerable.
	#
	# Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
	# and migrated your data accordingly.
	#
	# For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
	system.stateVersion = "24.05"; # Did you read the comment?

}
