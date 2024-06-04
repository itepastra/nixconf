{ config, pkgs, nix-colors, ... }:

{
  imports = [
    nix-colors.homeManagerModules.default
  ];

  # colorScheme = nix-colors.colorSchemes.catppuccin-macchiato;

  colorScheme = {
    slug = "test";
    name = "TestScheme";
    author = "Noa";
    palette = {
      base00 = "#000000";
      base01 = "#0000FF";
      base02 = "#00FF00";
      base03 = "#00FFFF";
      base04 = "#FF0000";
      base05 = "#FF00FF";
      base06 = "#FFFF00";
      base07 = "#FFFFFF";
      base08 = "#777777";
      base09 = "#7777FF";
      base0A = "#77FF77";
      base0B = "#77FFFF";
      base0C = "#FF7777";
      base0D = "#FF77FF";
      base0E = "#FFFF77";
      base0F = "#AAAAAA";
      text = "#222222";
      textInverted = "#DDDDDD";
      textMuted = "#DDDDDD";
      background = "#FFD2D2";
      backgroundMuted = "#CCCCCC";
      warn = "#FF0000";
      highlight = "#FBAF44";
      danger = "#F53C3C";
      succes = "#5BBD63";
      spotifyGreen = "#39A04A";
      border = "#5F5F5F";
      info = "#2CB6AF";
      ok = "#38B148";
    };
  };

}
