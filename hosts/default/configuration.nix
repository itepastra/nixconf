# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, nix-colors, ... }:

rec {
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix
			inputs.home-manager.nixosModules.default
			../../modules/games/steam.nix
		];

	# Bootloader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# LOVE me some blob
	hardware.enableRedistributableFirmware = true;
	hardware.enableAllFirmware = true;

	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement = {
			enable = true;
			finegrained = false;
		};
		open = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
	};
	hardware.opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
	};

	# Allow unfree packages
	nixpkgs.config = {
		allowUnfree = true;
		nvidia.acceptLicense = true;
	};

	networking = {
		hostName = "lambdaOS"; # Define your hostname.
		extraHosts = ''
			::1 noa.voorwaarts.nl
		'';
	};
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
			# auto-optimise-store = true;
			experimental-features = ["nix-command" "flakes"];
			substituters = ["https://hyprland.cachix.org" "https://cache.iog.io" "https://cuda-maintainers.cachix.org" ];
			trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=" ];
		};
		optimise.automatic = true;
		gc = {
			automatic = false;
			dates = "weekly";
			options = "--delete-older-than 7d";
		};
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


	# Configure console keymap
	console.keyMap = "us-acentos";

	users.groups.nixpow.members = [ "root" ];
	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users = {
		root = {
			hashedPassword = "!";
		};
		noa = {
			isNormalUser = true;
			description = "Noa Aarts";
			extraGroups = [ "networkmanager" "wheel" "nixpow" ];
			hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
		};
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

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		git
		zsh
		mangohud
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
	programs = {
		zsh.enable = true;

		hyprland = {
			enable = true;
			package = inputs.hyprland.packages.${pkgs.system}.hyprland;
			portalPackage = pkgs.xdg-desktop-portal-hyprland;
		};

		nix-ld.enable = true;
		nix-ld.libraries = with pkgs; [
			wayland
		];
	};

	modules.games.steam.enable = false;

	users.defaultUserShell = pkgs.zsh;

	security.rtkit.enable = true;

	services = {
		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};
		fail2ban = {
			enable = true;
			maxretry = 5;
			bantime = "1s";
			bantime-increment = {
				enable = true;
				formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
				maxtime = "1h";
				overalljails = true;
			};
			jails = {
				go-login.settings = {
					enabled = true;
					filter = "go-login";
					action = ''iptables-multiport[name=HTTP, port="http,https,2000"]'';
					logpath = "/home/noa/Documents/programming/SODS/login.log";
					backend = "systemd";
					findtime = 600;
					bantime = 600;
					maxretry = 5;
				};
			};
		};
		greetd = {
			enable = true;
			settings = rec {
				initial_session = {
					command = "${pkgs.hyprland}/bin/Hyprland";
					user = "noa";
				};
				default_session = initial_session;
			};
		};
		openssh = {
			enable = true;

			settings.PasswordAuthentication = false;
			settings.KbdInteractiveAuthentication = false;
		};
		xserver = {
			enable = true;
			xkb = {
				layout = "us";
				variant = "intl";
			};
			videoDrivers = [ "nvidia" ];
		};
		flatpak.enable = true;
	};

	systemd.timers."update-flake" = {
		wantedBy = [ "timers.target" ];
		timerConfig = {
			OnCalendar = "daily";
			Persistent = true;
		};
	};

	systemd.services."update-flake" = {
		script = ''
		nix flake update --commit-lock-file /home/noa/nixos/
		nixos-rebuild switch --flake /home/noa/nixos/
		git -C /home/noa/nixos/ push
		'';
		serviceConfig = {
			Type = "oneshot";
			User = "root";
		};
	};

	environment.etc = {
		"fail2ban/filter.d/go-login.local".text = pkgs.lib.mkDefault (pkgs.lib.mkAfter ''
			[Definition]
			failregex=^time= level=WARN msg=".*?" ip=<ADDR> status=4\d\d$
		'');
	};

	virtualisation.docker.enable = true;

	boot.kernelModules = [
		"v4l2loopback"
		"nct6775"
		"k10temp"
	];

	boot.extraModprobeConfig = ''
		options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
	'';
	security.polkit.enable = true;

	# Open ports in the firewall.
	networking.firewall.allowedTCPPorts = [ 80 443 53317 ];
	networking.firewall.allowedUDPPorts = [ 80 443 53317 ];
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
