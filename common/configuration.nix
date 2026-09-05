{ enableGraphics }:
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  sddm-theme = pkgs.elegant-sddm;
  sddm-theme-name = "Elegant";
in
{
  imports = [
    ../modules/steam
    ../hm-modules/neovim
    ../modules/users
    ../modules/podman
    ../modules/stylix
  ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  nixpkgs.config = {
    contentAdressedByDefault = true;
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

  environment.systemPackages = [
    pkgs.age-plugin-yubikey
    sddm-theme
  ];

  home-manager = {
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  # TODO: find list of fonts to install
  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    stix-two
    fira-code
    fira-code-symbols
    liberation_ttf
    maple-mono.NF
    newcomputermodern
    roboto
  ];

  xdg.portal = {
    enable = enableGraphics;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = if enableGraphics then pkgs.pinentry-curses else pkgs.pinentry-tty;
    };

    niri = {
      enable = enableGraphics;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
    nm-applet.enable = enableGraphics;

    wireshark.enable = enableGraphics;
    xwayland.enable = enableGraphics;
    zsh.enable = true;
  };

  modules = {
    games.steam.enable = enableGraphics;
  };

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    initrd.verbose = false;
    plymouth = rec {
      enable = enableGraphics;
      theme = "colorful";
      themePackages = [ (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ theme ]; }) ];
    };

    extraModulePackages = lib.mkIf enableGraphics [ config.boot.kernelPackages.v4l2loopback.out ];
    kernelModules = lib.mkIf enableGraphics [ "v4l2loopback" ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';

    kernelParams = lib.mkIf enableGraphics [
      "plymouth.use-simpledrm"
    ];
  };

  services = {
    glances = {
      enable = lib.mkDefault true;
      openFirewall = true;
      extraArgs = [
        "--webserver"
        "--disable-webui"
      ];
    };
    gvfs = {
      enable = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    gnome.gnome-keyring.enable = true;
    mullvad-vpn = {
      enable = true;
      gui.enable = enableGraphics;
    };
    displayManager = {
      defaultSession = lib.mkIf enableGraphics "niri";
      sddm = {
        enable = enableGraphics;
        wayland.enable = true;
        theme = sddm-theme-name;
        extraPackages = with pkgs.kdePackages; [
          sddm-theme
          breeze-icons
          kirigami
          libplasma
          plasma5support
          qtsvg
          qtvirtualkeyboard
        ];
      };
    };
    pcscd.enable = true; # for yubikey
    pipewire = {
      enable = enableGraphics;
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
    xserver = {
      enable = false;
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };
    udev.packages = [ pkgs.yubikey-personalization ];
    resolved.enable = false;
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.execWheelOnly = true;
    pam.services.sddm.enableGnomeKeyring = true;
  };

}
