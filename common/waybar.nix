{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		waybar
		font-awesome
	];
	programs.waybar = {
		enable = true;
		settings = {
			mainBar = {
				layer = "top";
				position = "top";
				height = 28;
				margin-top = 8;
				margin-left = 10;
				margin-right = 10;
				output = [
					"DP-3"
					"DP-2"
				];
				modules-left = [ "hyprland/workspaces" "tray" "custom/pronouns" "hyprland/window" ];
				modules-center = [ "clock" ];
				modules-right = [ "custom/vpn" "wireplumber" "network" "cpu" "memory" "temperature" "custom/poweroff" ];
				"clock" = {
					tooltip-format = "<big>{:%Y %B}</big>\n\n{calendar}";
					interval = 1;
					format = "{:%H:%M:%S}";
					format-alt = ":%Y-%m-%d %H:%M:%S}";
					on-click-middle = "gnome-clocks";
					calendar = {
						weeks-pos = "left";
						format = {
							today = "<span color='#FF6666'><u>{}</u></span>"; # TODO: use nix-colors
							weeks = "<span color='#707A8C'>{}</span>"; # TODO: use nix-colors
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
					tooltip = false;
				};
				"wireplumber" = {
					format = "{icon} {volume}% {format_source}";
					format-bluetooth = "󰂯 {icon} {volume}% {format_source}";
					format-bluetooth-muted = "󰂯 󰝟 {format_source}";
					format-muted = "󰝟 {format_source}";
					format-source = "󰍬";
					format-source-muted = "󰍭";
					format-icons = {
						headphone = "󰋋";
						hands-free = "󰋎";
						headset = "󰋎";
						phone = "";
						portable = "";
						car = "󰄋";
						default = [
							"󰕾"
							"󰕾"
							"󰕾"
						];
					};
					on-click = "pavucontrol"; # TODO: find an alternative
				};
				"custom/vpn" = {
					format = "VPN";
					exec = "echo '{\"class\": \"connected\"}'";
					exec-if = "test -d /proc/sys/net/ipv4/conf/tun0";
					return-type = "json";
					interval = 5;
	 			};
				"temperature" = {
					thermal-zone = 2;
					hwmon-path = "/sys/class/hwmon/hwmon3/temp1_input";
					critical-threshold = 80;
					format = "{temperatureC}°C {icon}";
					format-icons = ["" "" ""];
				};
				"custom/poweroff" = {
					format = "";
					on-click = "wofi-power";
					on-click-right = "swaylock";
				};
				"battery" = {
					states = {
						full = 100;
						good = 100;
						warning = 30;
						critical = 30;
					};
					format = "mouse: {capacity}% {icon}";
					format-charging = "mouse: {capacity}% {icon}";
					format-plugged = "mouse: {capacity}% {icon}";
					format-alt = "mouse: {time} {icon}";
					interval = 1;
					format-icons = [
						"󰂎"
						"󰁻"
						"󰁾"
						"󰂀"
						"󰁹"
					];
				};
				"hyprland/window" = {
					max-length = 36;
				};
				"network" = {
					format-wifi = "{essid} ({signalStrength}%) 󰖩";
					format-ethernet = "{ipaddr}/{cidr} 󰛳";
					tooltip-format = "{ifname} via {gwaddr} 󰛳";
					format-linked = "{ifname} (No IP) 󰛳";
					format-disconnected = "Disconnected ";
					format-alt = "{ifname}: {ipaddr}/{cidr}";
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
		style = ''
			* {
				/* `otf-font-awesome` is required to be installed for icons */
				font-family: "Maple Mono NF";
				font-size: 14px;
			}

			window#waybar {
				background-color: transparent;
				
				border-radius: 999px;
				color: #dddddd;
				transition-property: background-color;
				transition-duration: .5s;
			}
			window#waybar.hidden {
				opacity: 0.2;
			}

			window#waybar.termite {
				background-color: transparent;
			}

			window#waybar.chromium {
				background-color: transparent;
			}

			button {
				/* Use box-shadow instead of border so the text isn't offset */
				box-shadow: inset 0 -1px transparent;
				/* Avoid rounded borders under each button name */
				border: none;
				border-radius: 0;
			}

			/* https://githbackground: #000000ub.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
			button:hover {
				background: inherit;
				border-radius: 999px;
			}

			#workspaces button {    
				transition: all 0.2s;
				padding: 3px 3px 3px 5px;
				margin: 3px;
				min-width: 15px;
				min-height: 15px;
				background-color: transparent;
				color: #5F5F5F;
				border-radius: 999px;
			}

			#workspaces button:hover {
				background-color: #FBAF44;       
			}

			#workspaces button.active {
				color: #ffffff;
				font-weight: bold;
				background-color: #FBAF44;  
			}

			#workspaces button.urgent {    
				background-color: #eb4d4b;    
			}

			#clock,
			#battery,
			#cpu,
			#memory,
			#disk,
			#temperature,
			#backlight,
			#network,
			#pulseaudio,
			#wireplumber,
			#custom-media,
			#mode,
			#idle_inhibitor,
			#scratchpad,
			#tray,
			#custom-updates,
			#mpd {
				color: #5F5F5F;
				margin: 0px 2px;
				padding: 0 15px;
				
				border-radius: 999px;
				box-shadow: inset 0 0 0 1px #cccccc;
			}

			.modules-right > widget:last-child > #battery {
				margin-right: 0px;
			}

			#tray {    
				padding: 4px 10px;        
				border-radius: 999px 999px 999px 999px;
				box-shadow: inset 0px 0px 0 1px #cccccc;    
			}

			#window { 
				margin-left: 6px;
				color: #5F5F5F;
			}

			#workspaces {   
				margin: 0 4px;
				padding: 4px 4px;   
				border-radius: 999px;
				box-shadow: inset 0px 0px 0 1px #cccccc;
			}

			#cpu {
				border-radius: 999px 0px 0px 999px;
				margin-right: 0px;        
			}

			#memory {
				border-radius: 0px;
				padding: 0 10px;
				margin: 0px;
				box-shadow: inset 0px 2px 0 -1px #cccccc,
							inset 0px -2px 0 -1px #cccccc;
			}

			#clock {    
				box-shadow: none;
			}


			#battery {    
				min-width: 50px;
				border-radius: 999px;
				box-shadow: inset 0 0 0 1px #cccccc;
				background-color: #cccccc;
				transition: all 0.3s;
			}

			#battery.charging, #battery.plugged {   
				color: #5bbd63; 
				background-color: transparent;
				animation: batteryCharging 1.2s linear 0s infinite normal forwards,               
			}
			#battery.full {
				animation: batteryFull 7.0s linear 0s infinite normal forwards;    
			}
			#battery.critical:not(.charging) {    
				background-color: #ffd2d2;
				animation: batteryCritical 1.2s linear 0s infinite normal forwards;        
			}

			#network {     

			}

			#network.disconnected,
			#pulseaudio.muted {
				transition: all 0.2s;
				color: #cccccc;    
			}

			.custom-spotify {
				color: #39a04a;
				margin-right: 10px;
			}

			#custom-media.custom-vlc {
				background-color: #ffa000;
			}

			#temperature {
				margin-left: 0px;
				border-radius: 0px 999px 999px 0px;
			}

			#temperature.critical {
				background-color: transparent;
				color: #f53c3c;
			}

			#tray {    
				background-color: transparent;
			}


			#tray > .passive {
				-gtk-icon-effect: dim;
			}

			#tray > .needs-attention {
				background-color: #f53c3c;    
				border-radius: 999px;
			}

			#idle_inhibitor {
				background-color: #2d3436;
			}

			#idle_inhibitor.activated {
				background-color: #ecf0f1;
				color: #2d3436;
			}

			#language {
				background: #00b093;
				color: #740864;
				padding: 0 5px;
				margin: 0 5px;
				min-width: 16px;
			}

			#keyboard-state {
				background: #97e1ad;
				color: #000000;
				padding: 0 0px;
				margin: 0 5px;
				min-width: 16px;
			}

			#keyboard-state > label {
				padding: 0 5px;
			}

			#keyboard-state > label.locked {
				background: rgba(0, 0, 0, 0.05);
			}

			#scratchpad {
				background: rgba(0, 0, 0, 0.1);
			}
			#scratchpad.empty {
				background-color: transparent;
			}

			#custom-updates {
				box-shadow: inset 0 0 0 1px #cccccc;
				color: #888888;
				transition: all 0.5s;
			}

			#custom-updates.pending {
				box-shadow: inset 0 0 0 2px #fbaf44;
				color: #fbaf44;
				font-weight: bold;
				transition: all 0.5s;
			}

			tooltip {
				background-color: #eeeeee;
				border: 1px solid;
				border-color: #dddddd;    
				border-radius: 10px;
				color: #5F5F5F;
			}
			tooltip label {
				padding: 5px;
			}

			/* Keyframes ---------------------------------------------------------------- */

			@keyframes batteryCritical {
				0% {
					box-shadow: inset 0px 20px 8px -16px #f53c3c,
								inset 0px -20px 8px -16px #f53c3c;
					color: #f53c3c;
				}
				50% {
					box-shadow: inset 0px 12px 8px -16px #f53c3c,
								inset 0px -12px 8px -16px #f53c3c;
					color: #555555;
				} 
				100% {
					box-shadow: inset 0px 20px 8px -16px #f53c3c,
								inset 0px -20px 8px -16px #f53c3c;
					color: #f53c3c;
				}
			}

			@keyframes batteryCharging {
				0% {
					box-shadow: inset 0px 0px 8px 0px #2cb6af,
								inset 0px 20px 8px -18px  #38b148,
								inset 0px -20px 8px -18px  #38b148;                    
				}
				25% {
					box-shadow: inset 0px 0px 8px 0px #2cb6af,
								inset 14px 14px 8px -18px #38b148,
								inset -14px -14px 8px -18px #38b148;                
				}
				50% {
					box-shadow: inset 0px 0px 8px 0px #2cb6af,
								inset 20px 0px 8px -18px #38b148,
								inset -20px 0px 8px -18px #38b148;                    
				}
				75% {
					box-shadow: inset 0px 0px 8px 0px #2cb6af,
								inset 14px -14px 8px -18px #38b148,
								inset -14px 14px 8px -18px #38b148;                   
				}
				100% {
					box-shadow: inset 0px 0px 8px 0px #2cb6af,
								inset 0px -20px 8px -18px #38b148,
								inset 0px 20px 8px -18px #38b148;                  
				}
			}



			@keyframes batteryFull {
				0% {
					box-shadow: inset 0px 20px 8px -16px #87D96C,
								inset 0px -20px 8px -16px #87D96C;
					color: #87D96C;
				}
				25% {
					box-shadow: inset 0px 19px 8px -16px #87D96C,
								inset 0px -19px 8px -16px #87D96C;
					color: #87D96C;
				}
				50% {
					box-shadow: inset 0px 15px 8px -16px #87D96C,
								inset 0px -15px 8px -16px #87D96C;
					color: #87D96C;
				} 
				75% {
					box-shadow: inset 0px 19px 8px -16px #87D96C,
								inset 0px -19px 8px -16px #87D96C;
					color: #87D96C;
				}
				100% {
					box-shadow: inset 0px 20px 8px -16px #87D96C,
								inset 0px -20px 8px -16px #87D96C;
					color: #87D96C;
				}
			}
		'';
	};
}
