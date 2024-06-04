{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # needed for the nvim config, neovim itself is a system package already
    ripgrep

    # TODO: find how I can make this build dependencies only
    gnumake
    rustc
    python3
  ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = lib.fileContents ./init.lua;
  };
}
