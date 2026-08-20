{
  ...
}:
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      scrollback_lines = 5000;
    };
    shellIntegration = {
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
  };
}
