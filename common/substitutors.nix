{ config, lib, ... }: {
  nix = {
    settings = {
      # auto optimise every so often
      # auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        (lib.mkIf (config.networking.hostName != "nuOS") "https://cache.itepastra.nl")
        (lib.mkIf (config.networking.hostName == "nuOS") "http://192.168.42.5:38281")
        "https://hyprland.cachix.org"
        "https://cache.iog.io"
        "https://cuda-maintainers.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.iog.io"
      ];
      trusted-public-keys = [
        "cache.itepastra.nl:zCB+g5uXlDuFXbs9pI10UmidFQt17kFTaPywv+J33FQ="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];
      allowed-uris = [
        "github:"
        "gitlab:"
      ];
    };
    optimise.automatic = true;
  };
}
