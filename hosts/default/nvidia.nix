{ config, lib, pkgs, ... }: 
{
	hardware.opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
	};

	services.xserver.videoDriver = "nvidia";

	hardware.nvidia = {
		
		modesetting.enable = true;

		# NOTE change this if borked
		powerManagement = {
			enable = true;
			finegrained = false;
		};

		open = false;

		nvidiaSettings = true;

		package = config.boot.kernelPackages.nvidiaPackages.stable;
	};
}
