{
  lib,
  config,
  pkgs,
  ...
}:
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
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    programs.zsh = {
      enable = true;
      shellAliases = lib.mkIf cfg.enableAliases {
        update = "nix flake update --commit-lock-file $HOME/nixos && sudo nixos-rebuild switch --flake $HOME/nixos";
        nb = "nix build -L";
        ns = "nix shell -L";
      };
      initExtra = ''
        [[ ! -r /home/noa/.opam/opam-init/init.zsh ]] || source /home/noa/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
      '';
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
