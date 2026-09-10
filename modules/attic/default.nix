{
  pkgs,
  inputs,
  config,
  ...
}:
let
  attic = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic;
in
{
  age.secrets."attic/anemone" = {
    file = ../../secrets/attic/anemone.age;
    mode = "600";
  };

  environment.systemPackages = [
    attic
    (pkgs.writeShellScriptBin "nix-build-push" ''
      name="$1"
      if [ -z "$name" ]; then
        echo "Usage: nix-build-push <nixosConfiguration name>"
        exit 1
      fi

      store_path=$(nix build -L --no-link --print-out-paths ".#nixosConfigurations.''${name}.config.system.build.toplevel")
      if [ $? -ne 0 ]; then
        echo "Build failed"
        exit 1
      fi

      echo "Built: $store_path"
      sudo attic push anemone "$store_path"

      drv=$(nix path-info --derivation "$store_path")
      requisites=$(nix-store --query --requisites --include-outputs "$drv")

      echo "$requisites" | sudo xargs attic push anemone
    '')

  ];

  systemd.tmpfiles.rules = [
    "C /root/.config/attic/config.toml 0600 root root - ${
      (pkgs.formats.toml { }).generate "attic-config.toml" {
        default-server = "trench";
        servers.trench = {
          endpoint = "http://trench.reef";
          token-file = config.age.secrets."attic/anemone".path;
        };
      }
    }"
  ];

  nix.settings = {
    substituters = [ "http://trench.reef/anemone?priority=10" ];
    trusted-public-keys = [ "anemone:f/wBQ8yB5geTn96NjwRfbcoEvr8QuykN0iu0Rf2zUC8=" ];
    trusted-substituters = [ "http://trench.reef/anemone" ];
  };
}
