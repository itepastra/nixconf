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

          (lib.mkIf config.modules.apps.neovim.enableLanguages cargo)
          (lib.mkIf config.modules.apps.neovim.enableLanguages gcc)
          (lib.mkIf config.modules.apps.neovim.enableLanguages go)
          (lib.mkIf config.modules.apps.neovim.enableLanguages jdk22)
          (lib.mkIf config.modules.apps.neovim.enableLanguages lua51Packages.lua)
          (lib.mkIf config.modules.apps.neovim.enableLanguages nodejs)
          (lib.mkIf config.modules.apps.neovim.enableLanguages php83Packages.composer)
          (lib.mkIf config.modules.apps.neovim.enableLanguages php83)
          (lib.mkIf config.modules.apps.neovim.enableLanguages opam)
          (lib.mkIf config.modules.apps.neovim.enableLanguages
            (python3.withPackages (python-pkgs: [
              python-pkgs.pip
              python-pkgs.black
            ])))
        ];
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        extraLuaConfig = lib.fileContents ./init.lua;
      };
  };
}
