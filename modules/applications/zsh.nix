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
      initContent = ''
        command_not_found_handler() {
          local cmd="$1"

          # If the thing you typed is a regular file, try to open it
          if [[ -f "$cmd" ]]; then
              # Determine MIME type
              local mime
              mime=$(xdg-mime query filetype -- "$cmd" 2>/dev/null)

              if [[ -n "$mime" ]]; then
                  print "Opening '$cmd' with xdg-open (MIME: $mime)…"
                  xdg-open "$cmd" >/dev/null 2>&1 &
                  return 0
              else
                  print "No known MIME type for '$cmd'."
                  print "You can assign one using:"
                  print "  xdg-mime install <file>.xml"
                  print "  xdg-mime default <app>.desktop $cmd"
                  return 1
              fi
          fi

          # Default: real command not found
          print "zsh: command not found: $cmd"
          return 127
        }
      '';
    };
  };

}
