{ config, pkgs, nix-colors, ... }:

{
  imports = [
    nix-colors.homeManagerModules.default
  ];

  colorScheme = {
    slug = "dracumod";
    name = "ModifiedDracula";
    author = "Noa";
    palette = rec {
      base00 = "#26052e"; # background222c"
      base01 = "#950fad"; # lighter background"
      base02 = "#3A3C4E"; # selection background
      base03 = "#4D4F68"; # comments, invisibles, line highlighting
      base04 = "#626483"; # dark foreground
      base05 = "#E9E9F4"; # foreground
      base06 = "#f8f8f2"; # light foreground
      base07 = "#ffffff"; # lightest foreground
      base08 = "#ff5555"; # red
      base09 = "#f1fa8c"; # yellow
      base0A = "#EBFF87"; # classes, markup, search text highlight
      base0B = "#50fa7b"; # green
      base0C = "#8be9fd"; # cyan
      base0D = "#bd93f9"; # blue
      base0E = "#ff79c6"; # purple
      base0F = "#00F769"; # deprecated
      base10 = "#1D1D26"; # darker background
      base11 = "#1B1B23"; # darkest background
      base12 = "#ff6e6e"; # bright red
      base13 = "#ffffa5"; # bright yellow
      base14 = "#69ff94"; # bright green
      base15 = "#a4ffff"; # bright cyan
      base16 = "#d6acff"; # bright blue
      base17 = "#ff92df"; # bright purple
      taskbarText = base04;
      background_paper = "#000000";
      foreground_paper = "#26052e";
    };
  };

}
