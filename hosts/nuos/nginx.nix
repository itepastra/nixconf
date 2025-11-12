{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  enableFlurry = true;
  enableQubitQuilt = true;
in
{
  services.nginx =
    let

      extra = ''
        client_max_body_size 50000M;

        proxy_redirect     off;

        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;'';
      proxy = name: url: {
        forceSSL = true;
        useACMEHost = name;
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

      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      recommendedBrotliSettings = true;
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

      virtualHosts = lib.mkMerge [
        ({
          "noa.voorwaarts.nl" = {
            forceSSL = true;
            enableACME = true;
            extraConfig = extra;
            locations."/" = {
              proxyWebsockets = true;
              proxyPass = "http://192.168.42.5:8000";
            };
          };

          "images.noa.voorwaarts.nl" = proxy "noa.voorwaarts.nl" "http://localhost:2283/";
          "maintenance.noa.voorwaarts.nl" = proxy "noa.voorwaarts.nl" "http://192.168.42.5:5000/";
          "map.noa.voorwaarts.nl" = proxy "noa.voorwaarts.nl" "http://127.0.0.1:8123/";

          "itepastra.nl" = {
            forceSSL = true;
            enableACME = true;
            extraConfig = extra;
            locations."/" = {
              proxyWebsockets = true;
              proxyPass = "http://192.168.42.5:9001/";
            };
          };

          "calendar.itepastra.nl" = proxy "itepastra.nl" "http://[::1]:29341";

          # home-assistant proxy
          "home.itepastra.nl" = proxy "itepastra.nl" "http://[::1]:8123";

          "git.geenit.nl" = {
            forceSSL = true;
            enableACME = true;
            extraConfig = extra;
            locations."/" = {
              proxyWebsockets = true;
              proxyPass = "http://127.0.0.1:2929/";
            };
          };
        })
        (lib.mkIf (import ./toggles.nix).enableFlurry {
          "flurry.itepastra.nl" = proxy "itepastra.nl" "http://127.0.0.1:3000";
        })
        (lib.mkIf (import ./toggles.nix).enableQubitQuilt {
          "qq.geenit.nl" = {
            forceSSL = true;
            enableACME = true;
            extraConfig = extra;
            locations."/" = {
              root = inputs.qubit-quilt.packages."x86_64-linux".default;
            };
          };
        })
      ];
    };
}
