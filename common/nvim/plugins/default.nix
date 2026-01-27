{ lib, pkgs, ... }:
{
  imports = [
    ./conform.nix
    ./telescope.nix
    ./treesitter.nix
    ./gitsigns.nix
  ];
  config.programs.nixvim.plugins = {
    conform-nvim.enable = true;
    lspconfig.enable = true;
    telescope.enable = true;
    mini-statusline.enable = true;
    typst-preview.enable = true;
    web-devicons.enable = true;
    fugitive.enable = true;
    colorizer.enable = true;
    treesitter.enable = true;
    guess-indent.enable = true;
    gitsigns.enable = true;
  };
}
