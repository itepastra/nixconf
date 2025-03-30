{
  config,
  pkgs,
  inputs,
  nix-colors,
  ...
}:
{
  imports = [
    ./.
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.settings = {
    trusted-users = [ "noa" ];
    sandbox = true;
    show-trace = true;
    system-features = [
      "nixos-test"
      "recursive-nix"
    ];

    sandbox-paths = [ "/bin/sh=${pkgs.busybox-sandbox-shell.out}/bin/busybox" ];
  };

  networking = {
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      53317 # Localsend
      22000 # syncthing
    ];
    firewall.allowedUDPPorts = [
      53317
      22000 # syncthing
      21027 # syncthing
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        hashedPassword = "!";
      };
      noa = {
        isNormalUser = true;
        description = "Noa Aarts";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
          "wireshark"
          "dialout"
        ];
        hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
        openssh.authorizedKeys.keys = (import ./ssh-keys.nix);
      };
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
      inherit nix-colors;
    };
  };

  # TODO: find list of fonts to install
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    fira-code
    fira-code-symbols
    liberation_ttf
    maple-mono.NF
    newcomputermodern
  ];

  xdg.portal = {
    enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.system}.niri;
    };
    nm-applet.enable = true;

    wireshark.enable = true;
    zsh.enable = true;
  };

  modules = {
    games.steam.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    consoleLogLevel = 0;

    initrd.verbose = false;
    plymouth = rec {
      enable = true;
      theme = "colorful";
      themePackages = [ (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ theme ]; }) ];
    };

    kernelParams = [
      "plymouth.use-simpledrm"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "i915.fastboot=1"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    kernelModules = [
      "nct6775"
      "k10temp"
    ];

    loader = {
      timeout = 3;
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 100;
      };
    };
  };

  services = {
    displayManager = {
      defaultSession = "niri";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    pcscd.enable = true; # for yubikey
    desktopManager.plasma6 = {
      enable = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
    };
    thermald.enable = true;
    xserver = {
      enable = false;
      xkb = {
        layout = "us";
        variant = "altgr intl";
      };
    };
    udev.packages = [ pkgs.yubikey-personalization ];
  };

  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_27;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.execWheelOnly = true;
  };

  system = {
    switch.enableNg = true;
    rebuild.enableNg = true;
  };
}
