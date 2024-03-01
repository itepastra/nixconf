{ config, pkgs, inputs, ... }:

{

	programs.git = {
		enable = true;
		userName = "Noa Aarts";
		userEmail = "itepastra@gmail.com";
		extraConfig = {
			init = { defaultBranch = "main"; };
			safe.directory = "/etc/nixos";
		};
	};

}
