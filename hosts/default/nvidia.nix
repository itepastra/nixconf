{ config, lib, pkgs, ... }: 
{
	hardware.opengl = {
		enable = true;
		driSupport = false;
	};

	services.xserver.videoDrivers = [ "nvidia" ];

	hardware.nvidia = {
		
		modesetting.enable = true;

		# NOTE change this if borked
		powerManagement = {
			enable = false;
			finegrained = false;
		};

		open = false;

		nvidiaSettings = true;

		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};
}
