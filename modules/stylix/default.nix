{ pkgs, ... }: {

  stylix = {
    enable = true;
    autoEnable = true;
    fonts = {
      emoji = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";
      };
      monospace = {
        package = pkgs.maple-mono.NF;
        name = "Maple Mono NF";
      };
      sansSerif = {
        name = "Lexend";
        package = pkgs.lexend;
      };
      serif = {
        name = "Lexend";
        package = pkgs.lexend;
      };
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    targets = {
      kmscon.enable = false;
      plymouth.enable = false;
      qt = {
        enable = true;
        platform = pkgs.lib.mkForce "qtct";
      };
    };

  };

}
