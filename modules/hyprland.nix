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
  };

  imports = [
    ./waybar/default.nix
    ./wofi.nix
    ./dunst.nix
  ];
  config = lib.mkIf cfg.enable {
    modules = {
      waybar = {
	modules = {
          left = [ "hyprland/workspaces" "tray" "hyprland/window" ];
	  center = [ "clock" ];
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
      wl-clipboard

      slurp
      grim

      hypridle # TODO: remove when fixed with config
      playerctl
    ];


    xdg.portal.configPackages = [ cfg.package ];

    services.playerctld.enable = true;
    wayland.windowManager.hyprland = {
      enable = true;
      package = cfg.package;
      settings = {
	monitor = [
	  "DP-3,2560x1440@360,2560x0,1"
	  "DP-2,2560x1440@144,0x0,1"
	];
	windowrulev2 = [
	  "opacity 1.0 0.6,class:^(kitty)$"
	  "stayfocused,class:^(wofi)$"
	];
	env = [
	  "WLR_NO_HARDWARE_CURSORS,1"
	];
	exec-once = [
	  "waybar"
	  "dunst"
	  "automapaper -C ${config.xdg.configHome}/automapaper/config.toml"
	  "automapaper -C ${config.xdg.configHome}/automapaper/config2nd.toml"
	  "hyprctl dispatcher focusmonitor 1"
	  "hypridle"
	];
	general = {
	  sensitivity = "1.2";
	  gaps_in = "2";
	  gaps_out = "3";
	  border_size = "3";
	  "col.active_border"="0xff950fad";
	  "col.inactive_border"="0xff26052e";
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
	  "$mod,Return,exec,${cfg.terminal.pname}"
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
		ws = builtins.toString (x);
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
  };
}
