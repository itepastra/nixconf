{ pkgs, lib, config, ... }:
{
  options.modules.apps.neovim = {
    enableLanguages = lib.mkEnableOption "enable LSP languages";
  };

  config = {
    programs.neovim =
      {
        enable = true;
        extraPackages = with pkgs; lib.mkMerge [
          [
            ripgrep
            luarocks
            gnumake
            wget
            nixpkgs-fmt
            tree-sitter
            fd
          ]
          (lib.mkIf config.modules.apps.neovim.enableLanguages [
            cargo
            gcc
            go
            jdk22
            luaPackages.lua
            nodejs
            php83Packages.composer
            php83
            opam
            (python3.withPackages (python-pkgs: [
              python-pkgs.pip
              python-pkgs.black
            ]))
          ])
        ];
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        extraLuaConfig = lib.fileContents
          ./init.lua;
      };
  };
}
