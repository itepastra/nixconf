{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.modules.apps.neovim = {
    enableLanguages = lib.mkEnableOption "enable LSP languages";
  };

  config = {
    programs.neovim = {
      enable = true;
      extraPackages = with pkgs; [
        ripgrep
        luarocks
        gnumake
        wget
        tree-sitter
        fd
        nixfmt-rfc-style
        gcc
        typst
        python313
      ];
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      extraLuaConfig =
        builtins.replaceStrings
          [ "@websocat@" "@tinymist@" ]
          [ "${pkgs.websocat}/bin/websocat" "${pkgs.tinymist}/bin/tinymist" ]
          (lib.fileContents ./init.lua);
    };
  };
}
