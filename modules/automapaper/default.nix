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

	config = lib.mkIf cfg.enable (
	let
		displays = lib.attrsets.mapAttrs (displayName: displayConfig:
			let 
				init = builtins.toFile "init.frag" displayConfig.init;
				state = builtins.toFile "state.frag" displayConfig.state;
				display = builtins.toFile "display.frag" displayConfig.display;
			in
			''
			[display]
			name="${displayName}"
			horizontal=${displayConfig.horizontal}
			vertical=${displayConfig.vertical}
			tps=${displayConfig.tps}
			state_frag="${state}"
			init_frag="${init}"
			display_frag="${display}"
			cycles=${displayConfig.cycles}
			frames_per_tick=${displayConfig.frames_per_tick}
			''
		) cfg.configurations;
	in
	{
		wayland.windowManager.hyprland.exec-once =
			lib.mkIf config.modules.hyprland.enable (
				lib.mapAttrsToList (name: config: 
					"${
						inputs.automapaper.packages.${pkgs.system}.default
					}/bin/automapaper -C ${
						builtins.toFile "${name}.toml" config
					}") cfg.displays
			);
	});

}
