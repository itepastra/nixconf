{ config, options, lib, ... }:
let
  cfg = config.modules.websites;
in
{
  options.modules.nginx =
    {
      enable = lib.mkEnableOption "enable web hosting";
      cert_mail = lib.mkOption {
        type = lib.types.str;
        description = "the email address the certificate will be requested to";
      };
      mainDomains = lib.mkOption {
        description = "nginx domains for which a certificate is needed";
        type = with lib.types; attrsOf (submodule {
          options =
            let
              proxyOption = lib.mkOption { type = int; description = "what url to proxy the requests to"; };
            in
            {
              enable = lib.mkEnableOption "enable this website";
              extra_sites = attrsOf
                (submodule {
                  options = {
                    enable = lib.mkEnableOption "enable this website";
                    proxy = proxyOption;
                  };
                });
              proxy = proxyOption;
            };
        });
      };
    };
  config = lib.mkIf cfg.enable (
    let
      hostnames = lib.lists.flatten (
        lib.attrsets.mapAttrsToList
          (
            name: config:
              lib.mkIf config.enable (
                [ name ] ++ lib.attrsets.mapAttrsToList (n: c: lib.mkIf c.enable n) config.extra_sites
              )
          )
          cfg.mainDomains
      );
      certs = lib.attrsets.MapAttrs
        (
          name: config:
            lib.mkIf config.enable {
              extraDomainNames = lib.attrsets.MapAttrsToList (n: c: lib.mkIf c.enable n) config.extra_sites;
            }
        )
        cfg.mainDomains;
      hosts = lib.attrsets.MapAtrrs
        (
          name: config:
            let
              extra = ''
                client_max_body_size 50000M;

                proxy_set_header Host              $host;
                proxy_set_header X-Real-IP         $remote_addr;
                proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;

                proxy_http_version 1.1;
                proxy_set_header   Upgrade    $http_upgrade;
                proxy_set_header   Connection "upgrade";
                proxy_redirect     off;

                proxy_read_timeout 600s;
                proxy_send_timeout 600s;
                send_timeout       600s;'';
              proxy = url: {
                forceSSL = true;
                useACMEHost = name;
                extraConfig = extra;
                locations."/" = {
                  proxyPass = url;
                };
              };
            in
            lib.mkIf config.enable (
              lib.mkMerge (
                {
                  forceSSL = true;
                  enableACME = true;
                  extraConfig = extra;
                  locations."/" = {
                    proxyPass = config.proxy;
                  };
                }
                ++ (lib.attrsets.MapAttrsToList
                  (n: c: lib.mkIf c.enable (proxy c.proxy))
                  config.extra_sites)
              )
            )
        )
        cfg.mainDomains;
    in
    {
      networking.hosts = {
        # NOTE: this is needed because I don't have hairpin nat. :(
        "127.0.0.1" = hostnames;
      };
      security.acme = {
        acceptTerms = true;
        defaults.email = cfg.cert_mail;
        certs = certs;
      };
      services.nginx = {
        enable = true;

        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;

        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

        virtualHosts = hosts;
      };
    }
  );
}
