{ config, pkgs, inputs, ... }:

{
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
