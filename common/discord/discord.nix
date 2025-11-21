{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];
  home.file.".config/Vencord/themes/midnight.theme.css".source = ./theme.css;
  programs.nixcord = {
    enable = true;
    quickCss = "";
    config = {
      frameless = true;
      useQuickCss = true;
      plugins = {
        blurNsfw.enable = true;
        fakeNitro.enable = true;
        fixSpotifyEmbeds.enable = true;
        callTimer.enable = true;
        clearUrLs.enable = true;
        fixYoutubeEmbeds.enable = true;
        noF1.enable = true;
        petpet.enable = true;
        spotifyCrack.enable = true;
        typingTweaks.enable = true;
        unindent.enable = true;
        validReply.enable = true;
      };
    };
    extraConfig = {
      enabledThemes = [ "midnight.theme.css" ];
    };
  };
}
