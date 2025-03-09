{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixcord.homeManagerModules.nixcord
  ];
  programs.nixcord = {
    enable = true;
    config = {
      frameless = true;
      plugins = {
        blurNSFW.enable = true;
        fakeNitro.enable = true;
        fixSpotifyEmbeds.enable = true;
        callTimer.enable = true;
        clearURLs.enable = true;
        fixYoutubeEmbeds.enable = true;
        noF1.enable = true;
        petpet.enable = true;
        replaceGoogleSearch = {
          enable = true;
          customEngineName = "duck duck go";
          customEngineURL = "https://duckduckgo.com/";
        };
        spotifyCrack.enable = true;
        typingTweaks.enable = true;
        unindent.enable = true;
        validReply.enable = true;
      };
    };
  };
}
