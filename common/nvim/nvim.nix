{ pkgs, lib, config, ... }:
{
  options.modules.apps.neovim = {
    enableLanguages = lib.mkEnableOption "enable LSP languages";
  };

  config = {
    programs.neovim =
      {
        enable = true;
        extraPackages = with pkgs; [
          ripgrep
          luarocks
          gnumake
          wget
          nixpkgs-fmt
          tree-sitter
          fd
        ];
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        extraLuaConfig = lib.fileContents
          ./init.lua;
      };
  };
}
