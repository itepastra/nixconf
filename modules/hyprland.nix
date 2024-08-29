{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.modules.hyprland;
in
{
  options.modules.hyprland = {
    enable = lib.mkEnableOption "enable hyprland";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.hyprland;
      example = lib.literalExpression ''inputs.hyprland.packages.${pkgs.system}.hyprland'';
    };
    terminal = lib.mkOption {
      type = lib.types.package;
      default = pkgs.kitty;
      description = "What terminal emulator should be used in hyprland";
    };
    wallpapers.automapaper = {
      enable = lib.mkEnableOption "enable automapaper";
    };
    portalPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.xdg-desktop-portal-hyprland;
    };
  };

  imports = [
    ./waybar/default.nix
    ./wofi.nix
    ./dunst.nix
    ./automapaper
  ];

  config = lib.mkIf cfg.enable {
    modules = {
      automapaper = {
        enable = lib.mkDefault true;
        hyprland = cfg.enable;
      };
      waybar = {
        modules = {
          left = [ "hyprland/workspaces" "tray" "hyprland/window" ];
          center = [ "clock" "custom/spotify" ];
          right = [ "custom/vpn" "wireplumber" "network" "cpu" "memory" "custom/poweroff" ];
        };
        enable = lib.mkDefault true;
      };
      wofi.enable = lib.mkDefault true;
      dunst.enable = lib.mkDefault true;
    };
    # these are necessary for the config to function correctly
    home.packages = with pkgs; [
      # I always want these with hyprland anyways
      libnotify # to enable the notify-send command
      wl-clipboard # wl-copy and wl-paste

      playerctl
    ];


    xdg.portal = {
      extraPortals = [ cfg.portalPackage ];
      config.common.default = "*";
    };

    services.playerctld.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      package = cfg.package;
      settings = {
        monitor = [
          "DP-3,2560x1440@360,2560x0,1"
          "DP-2,2560x1440@144,0x0,1"
          "Unknown-1,disable" # NOTE: still borked on 04-06-2024
        ];
        windowrulev2 = [
          "opacity 1.0 0.6,class:^(kitty)$"
          "stayfocused,class:^(wofi)$"
        ];
        env = [
          "WLR_NO_HARDWARE_CURSORS,1"
        ];
        exec-once = [
          "${pkgs.waybar}/bin/waybar"
          "${pkgs.dunst}/bin/dunst"
          "${cfg.package}/bin/hyprctl dispatcher focusmonitor 1"
          "${pkgs.hypridle}/bin/hypridle"
          "${pkgs.keepassxc}/bin/keepassxc"
          "${pkgs.planify}/bin/planify"
        ];
        general = {
          sensitivity = "1.2";
          gaps_in = "2";
          gaps_out = "3";
          border_size = "3";
          "col.active_border" = "0xff${config.colorScheme.palette.base01}";
          "col.inactive_border" = "0xff${config.colorScheme.palette.base00}";
        };
        misc = {
          key_press_enables_dpms = true;
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
          "$mod,Return,exec,${cfg.terminal}/bin/${cfg.terminal.pname}"
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
          "SUPERSHIFT,S,exec,${pkgs.hyprshot}/bin/hyprshot -m region --clipboard-only"
          "$mod,f11,fullscreen,0"
          ",XF86AudioLowerVolume,exec,${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 1%-"
          ",XF86AudioRaiseVolume,exec,${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_SINK@ 1%+"
          ",XF86AudioMute,exec,${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ toggle"
          ",XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl play-pause"
          ",XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl previous"
          ",XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl next"
          "$mod,mouse_up,workspace,r-1"
          "$mod,mouse_down,workspace,r+1"
        ]
        ++ (
          builtins.concatLists (builtins.genList
            (
              x:
              let
                ws = builtins.toString (x);
              in
              [
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
  };
}
