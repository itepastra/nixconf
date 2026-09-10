{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = (pkgs.firefox.override { nativeMessagingHosts = [ pkgs.passff-host ]; });
    profiles = {
      profile_0 = {
        id = 0;
        name = "profile_0";
        isDefault = true;
        search = {
          default = "kagi";
          force = true;
          order = [
            "kagi"
            "ddg"
          ];
          engines = {
            nix-packages = {
              name = "Nix Packages";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];

              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };

            nixos-wiki = {
              name = "NixOS Wiki";
              urls = [ { template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; } ];
              iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
              definedAliases = [ "@nw" ];
            };

            kagi = {
              name = "Kagi";
              urls = [
                {
                  template = "https://kagi.com/search?q=%s";
                }
              ];
              definedAliases = [ "@k" ];
            };

            bing.metaData.hidden = true;
            google.metaData.hidden = true;
            ebay.metaData.hidden = true;
            ecosia.metaData.hidden = true;
          };
        };
        settings = {

        };
      };
    };
  };

  home.packages = [
    pkgs.pinentry-qt
  ];

  home.file = {
    "ykcs/ykcs11.so".source = "${pkgs.yubico-piv-tool}/lib/libykcs11.so";
  };
}
