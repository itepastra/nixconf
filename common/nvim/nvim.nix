{ pkgs, lib, ... }:
{
  programs.neovim =
    {
      enable = true;
      extraPackages = with pkgs; [
        ripgrep
        luarocks
        gnumake
        rustc
        (python3.withPackages (python-pkgs: [
          python-pkgs.pip
        ]))
        wget
        julia
        gopls
        nixpkgs-fmt
        lua51Packages.lua
        tree-sitter
        php83Packages.composer
        php83
        temurin-jre-bin
        fd
      ];
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraLuaConfig = lib.fileContents ./init.lua;
    };
}
