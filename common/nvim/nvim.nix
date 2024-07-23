{ pkgs, lib, ... }:
{
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

        cargo
        gcc
        go
        julia
        jdk22
        lua51Packages.lua
        nodejs
        php83Packages.composer
        php83
        (python3.withPackages (python-pkgs: [
          python-pkgs.pip
        ]))
      ];
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraLuaConfig = lib.fileContents ./init.lua;
    };
}
