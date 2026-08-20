{ pkgs, ... }:
{
  config.programs.nixvim.plugins.treesitter = {
    highlight.enable = true;
    indent.enable = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };
}
