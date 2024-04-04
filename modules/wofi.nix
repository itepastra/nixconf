{ lib, config, pkgs, inputs, ... }:
let
	cfg = config.modules.wofi;
in
{
	options.modules.wofi = {
		enable = lib.mkEnableOption "enable wofi app launcher";
		lazy = lib.mkEnableOption "enable lazy desktop entries";
	};
	imports = [
		../common/colors.nix
	];
	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			(lib.mkIf cfg.lazy inputs.lazy.packages.${pkgs.system}.lazy-desktop)
			(lib.mkIf cfg.lazy (writeShellApplication { 
				name = "lo"; 
				runtimeInputs = [ xdg-utils ];
				text = ''
					echo "opening $*"
					xdg-open "$*"
				'';
			}))
			(lib.mkIf cfg.lazy (writeShellApplication { 
				name = "mt"; 
				runtimeInputs = [ xdg-utils ];
				text = ''xdg-mime query filetype "$@"'';
			}))
			(writeShellScriptBin "wofi-launch" ''
					${wofi}/bin/wofi --show drun
				'')
			(writeShellScriptBin "wofi-power" ''
					lock="Lock"
					poweroff="Poweroff"
					reboot="Reboot"
					sleep="Suspend"
					
					selected_option=$(echo -e "$lock\n$sleep\n$reboot\n$poweroff" | wofi --dmenu -i -p "Powermenu")

					if [ "$selected_option" == "$lock" ]
					then
						echo "lock"
						swaylock
					elif [ "$selected_option" == "$poweroff" ]
					then
						echo "poweroff"
						poweroff
					elif [ "$selected_option" == "$reboot" ]
					then
						echo "reboot"
						reboot
					elif [ "$selected_option" == "$sleep" ]
					then
						echo "sleep"
						suspend
					else
						echo "No match"
					fi
				'')
		];
		programs.wofi = {
			enable = true;
			settings = {
			
			};
			style = ''
				* {
					outline: none;
					outline-style: none;
				}

				#window {
					margin: 10px;
					border: none;
					background-color: #${config.colorScheme.palette.background};
					border-radius: 10px;
					font-family:
						JetBrains Mono NF,
						monospace;
					font-weight: bold;
					font-size: 14px;
				}

				#outer-box {
					margin: 10px;
					border: 2px #${config.colorScheme.palette.backgroundMuted};
					border-radius: 10px;
					background-color: transparent;
				}

				#input {
					border: none;
					border-radius: 10px;
					margin-left: 2px;
					color: #${config.colorScheme.palette.info};
					outline-style: none;
					background-color: #${config.colorScheme.palette.background};
				}

				#scroll {
					border: 10px solid #${config.colorScheme.palette.border};
					border-radius: 10px;
					/*padding-right: 10px;*/
					outline: none;
					background-color: #${config.colorScheme.palette.background};
				}

				#inner-box {
					border: none;
					border-radius: 10px;
					background-color: transparent;
				}

				#entry {
					border: none;
					/*border-radius: 10px;
						margin-right: 15px;
						margin-left: 15px;*/
					padding-right: 10px;
					padding-left: 10px;
					color: #${config.colorScheme.palette.text};
					background-color: #${config.colorScheme.palette.background};
				}
				#entry:selected {
					border: none;
					background-color: #${config.colorScheme.palette.info};
				}

				#text:selected {
					border: none;
					color: #${config.colorScheme.palette.textMuted};
				}

				#img {
					background-color: transparent;
					margin-right: 6px;
				}
			'';
		};
	};
}
