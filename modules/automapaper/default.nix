{ lib, config, pkgs, inputs, ... }:
let 
	cfg = config.modules.automapaper;
in
{
	options.modules.automapaper = {
		enable = lib.mkEnableOption "enable automapaper";
		configurations = lib.mkOption {
			description = "automapaper configurations per monitor";
			type = with lib.types; attrsOf (submodule {
				options = {
					init = mkOption {
						type = str;
						description = "the shader executed to get the state for the initialisation, and re-initialisation steps";
					};
					state = mkOption {
						type = str;
						description = "the shader executed to increment the state to the next generation";
					};
					display = mkOption {
						type = str;
						description = "the shader executed to display the state to the monitor";
					};
					horizontal = mkOption {
						type = int;
						description = "the amount of horizontal cells in the state";
					};
					vertical = mkOption {
						type = int;
						description = "the amount of vertical cells in the state";
					};
					tps = {
						type = int;
						description = "the amount of ticks to simulate each second";
					};
					cycles = {
						type = int;
						description = "the amount of state increments before the init shader is called again";
					};
					frames_per_tick = {
						type = int;
						description = "the amount of times to call the display shader for each iteration of the state shader";
					};
				};
			});
		};
	};


	config = lib.mkIf cfg.enable {
		home.packages = [
			inputs.automapaper.packages.${pkgs.system}.default
		];

		home.file = {
			"${config.xdg.configHome}/automapaper/config.toml".source = ./config.toml;
			"${config.xdg.configHome}/automapaper/config2nd.toml".source = ./config2nd.toml;
			"${config.xdg.configHome}/automapaper/state.frag".source = ./state.frag;
			"${config.xdg.configHome}/automapaper/init.frag".source = ./init.frag;
			"${config.xdg.configHome}/automapaper/display.frag".source = ./display.frag;
		};
	};

}
