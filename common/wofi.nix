{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		(writeShellScriptBin "wofi-launch" ''
				${wofi}/bin/wofi --show drun
			'')
		(writeShellScriptBin "wofi-power" ''
				lock="Lock"
				logout="Logout"
				poweroff="Poweroff"
				reboot="Reboot"
				sleep="Suspend"
				
				selected_option=$(echo -e "$lock\n$logout\n$sleep\n$reboot\n$poweroff" | wofi --dmenu -i -p "Powermenu")

				if [ "$selected_option" == "$lock" ]
				then
					echo "lock"
					swaylock
				elif [ "$selected_option" == "$logout" ]
				then
					echo "logout"
					loginctl terminate-user `whoami`
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
				background-color: #030035;
				border-radius: 10px;
				font-family:
					JetBrains Mono NF,
					monospace;
				font-weight: bold;
				font-size: 14px;
			}

			#outer-box {
				margin: 10px;
				border: 2px @lavender;
				border-radius: 10px;
				background-color: transparent;
			}

			#input {
				border: none;
				border-radius: 10px;
				margin-left: 2px;
				color: @text;
				outline-style: none;
				background-color: @base;
			}

			#scroll {
				border: 10px solid @mantle;
				border-radius: 10px;
				/*padding-right: 10px;*/
				outline: none;
				background-color: @base;
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
				color: @subtext0;
				background-color: @base;
			}
			#entry:selected {
				border: none;
				background-color: @green;
			}

			#text:selected {
				border: none;
				color: @crust;
			}

			#img {
				background-color: transparent;
				margin-right: 6px;
			}
		'';
	};

}
