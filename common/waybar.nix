{ config, pkgs, inputs, ... }:

{
	programs.waybar = {
		enable = true;
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 28;
				output = [
					"DP-3"
					"DP-2"
				];
				modules-left = [ "hyprland/workspaces" "tray" "custom/pronouns" "custom/spotify" ];
				modules-center = [ "hyprland/window" "clock" ];
				modules-right = [ "custom/vpn" "wireplumber" "network" "cpu" "memory" "keyboard-state" "custom/poweroff" ];
				"clock" = {
					tooltip-format = "<big>{:%Y %B}</big>\n\n<small>{calendar}</small>";
					interval = 1;
					format = "{:%H:%M:%S}";
					format-alt = ":%Y-%m-%d %H:%M:%S}";
					on-click-middle = "gnome-clocks";
					calendar = {
						weeks-pos = "left";
						format = {
							today = "<span color='#FF6666'><u>{}</u></span>";
							weeks = "<span color='#707A8C'>{}</span>";
						};
					};
				};
				"tray".spacing = 10;
				"cpu" = {
					format = "cpu: {usage}%";
					tooltip = false;
				};
				"memory" = {
					format = "mem: {}%";
				};
				"wireplumber" = {
					format = "{volume}%";
				};
				"custom/vpn" = {
					format = "VPN";
					exec = "echo '{\"class\": \"connected\"}'";
					exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
					return-type = "json";
					interval = 5;
				};
				"custom/poweroff" = {
					# TODO fix format 
					format = "P";
					on-click = "wofi-power";
					on-click-right = "swaylock";
				};
				"custom/pronouns" = {
					format = "{}";
					exec = "${config.xdg.configHome}/waybar/pronouns";
					interval = 5;
				};
				"hyprland/workspaces" = {
					format = "{name}";
					on-click = "activate";
					sort-by = "id";
				};
			};
		};
		style = ../styles/waybar.css;
	};

}
