{ lib, config, pkgs, ... }:
let 
	cfg = config.modules.apps.zsh;
in
{
	options.modules.apps.zsh = {
		enable = lib.mkEnableOption "enable zsh with oh-my-zsh";
		enableAliases = lib.mkEnableOption "whether to enable shellAliases";
	};

	config = lib.mkIf cfg.enable {
		programs.direnv = {
			enable=true;
			enableZshIntegration=true;
			nix-direnv.enable=true;
		};
		programs.zsh = {
			enable=true;
			shellAliases = lib.mkIf cfg.enableAliases {
				ll = "lsd -l";
				lt = "lsd -l --tree";
				update = "nix flake update --commit-lock-file $HOME/nixos && sudo nixos-rebuild switch --flake $HOME/nixos";
			};
			history = {
				path = "${config.xdg.dataHome}/zsh/history";
				size = 10000;
			};
			oh-my-zsh = {
				enable = true;
				plugins = [ "git" ];
				theme = "frisk";
			};
		};
	};

}
