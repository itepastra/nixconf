{ ... }:
{
  programs.prismlauncher = {
    enable = true;
    settings = {
      ConsoleMaxLines = 100000;
    };
  };
}
