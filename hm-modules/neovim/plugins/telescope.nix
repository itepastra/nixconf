{ config, ... }:
{
  config.programs.nixvim = {
    dependencies.ripgrep.enable = config.programs.nixvim.plugins.telescope.enable;
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>sh" = "help_tags";
        "<leader>sk" = "keymaps";
        "<leader>sf" = "find_files";
        "<leader>ss" = "builtin";
        "<leader>sw" = "grep_string";
        "<leader>sg" = "live_grep";
        "<leader>sd" = "diagnostics";
        "<leader>sr" = "resume";
        "<leader>s." = "oldfiles";
        "<leader><leader>" = "buffers";
      };
    };
  };
}
