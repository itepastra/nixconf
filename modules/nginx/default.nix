{
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [ ../../config/info ];

  options.modules.nginx = {
    proxies = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            url = lib.mkOption {
              type = lib.types.str;
            };
            proxy_to = lib.mkOption {
              type = lib.types.str;
            };
            enableSSL = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = {
    services.nginx =
      let
        extra = ''
          client_max_body_size 50000M;

          proxy_redirect     off;

          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout       600s;
        '';
        proxy = url: ssl: {
          forceSSL = ssl;
          enableACME = ssl;
          extraConfig = extra;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = url;
          };
        };
      in
      {
        enable = true;
        package = pkgs.nginx.override {
          modules = [ pkgs.nginxModules.brotli ];
        };

        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

        virtualHosts = lib.listToAttrs (
          builtins.map (
            {
              url,
              proxy_to,
              enableSSL,
            }:
            {
              name = url;
              value = proxy proxy_to enableSSL;
            }
          ) config.modules.nginx.proxies
        );
      };

    security.acme = {
      acceptTerms = true;
      defaults.email = config.modules.info.noa.email;
      certs = lib.listToAttrs (
        map (
          { url, ... }:
          {
            name = "${url}";
            value = { };
          }
        ) (lib.filter ({ enableSSL, ... }: enableSSL) config.modules.nginx.proxies)
      );
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        80
        443
      ];
    };
  };
}
