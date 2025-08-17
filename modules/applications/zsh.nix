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
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      shellAliases = {
        nb = "nix build -L";
        nbi = "nix build -L -f .";
        ns = "nix shell -L";
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
      loginExtra = ''
        eval "$(zoxide init --cmd cmd zsh)"
      '';
    };
  };

}
