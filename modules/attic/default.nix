{
  pkgs,
  lib,
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
      sudo attic push anemone "$store_path" --ignore-upstream-cache-filter

      drv=$(nix path-info --derivation "$store_path")
      requisites=$(nix-store --query --requisites --include-outputs "$drv")

      echo "$requisites" | sudo xargs attic push --ignore-upstream-cache-filter anemone
    '')
    (pkgs.writeShellScriptBin "nix-shell-push" ''
      if [ -z "$IN_NIX_SHELL" ] && [ -z "$name" ]; then
        echo "Not in a nix shell"
        exit 1
      fi

      paths=""
      for var in $buildInputs $nativeBuildInputs $propagatedBuildInputs $propagatedNativeBuildInputs; do
        paths="$paths $var"
      done

      if [ -z "$paths" ]; then
        echo "No build inputs found in environment"
        exit 1
      fi

      requisites=$(echo "$paths" | tr ' ' '\n' | grep -v '^$' | while read -r p; do
        drv=$(nix path-info --derivation "$p")
        if [ -n "$drv" ]; then
          nix-store --query --requisites --include-outputs "$drv"
        fi
      done)

      echo "$requisites" | sort -u | sudo xargs attic push --ignore-upstream-cache-filter anemone
    '')
    (pkgs.writeShellScriptBin "nix-push" ''
      requisites=""

      for name in "$@"; do
        # Build the derivation and get the output store path
        store_paths=$(NIXPKGS_ALLOW_UNFREE=1 nix build --no-link --print-out-paths --impure -L "$name")
        if [ -n "$store_paths" ]; then
          while IFS= read -r store_path; do
            reqs=$(nix-store --query --requisites "$store_path")
            requisites="$requisites"$'\n'"$reqs"
          done <<< "$store_paths"
        else
          echo "Warning: could not build '$name'" >&2
        fi
      done

      if [ -z "$requisites" ]; then
        echo "No requisites found, nothing to push." >&2
        exit 1
      fi

      echo "$requisites" | sort -u | xargs sudo attic push --ignore-upstream-cache-filter anemone    '')
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

  nix.extraOptions = ''
    !include /etc/nix/nix.conf.d/10-attic.conf
  '';

  # configuration.nix
  environment.etc."NetworkManager/dispatcher.d/99-nix-attic" = {
    mode = "0755";
    text = ''
      #!${lib.getExe pkgs.bash}

      HOME_SSID="niet-bestaand-netwerk"
      CONF=/etc/nix/nix.conf.d/10-attic.conf
      ATTIC_SUBSTITUTER="http://trench.reef/anemone?priority=10"
      ATTIC_KEY="anemone:f/wBQ8yB5geTn96NjwRfbcoEvr8QuykN0iu0Rf2zUC8="

      wifi_active() {
        ${lib.getExe pkgs.networkmanager}/bin/nmcli -g type,state dev | grep -q "^wifi:connected"
      }

      at_home_wifi() {
        [[ "$CONNECTION_ID" == "$HOME_SSID" ]]
      }

      vpn_active() {
        ${lib.getExe' pkgs.iproute2 "ip"} link show reef0 &>/dev/null && \
        ${lib.getExe' pkgs.iproute2 "ip"} link show reef0 | grep -q 'UP'
      }

      enable_cache() {
        local priority="$1"
        mkdir -p "$(dirname "$CONF")"
        cat > "$CONF" <<EOF
      extra-substituters = $ATTIC_SUBSTITUTER?priority=''${priority}
      extra-trusted-public-keys = $ATTIC_KEY
      extra-trusted-substituters = http://trench.reef/anemone
      EOF
        ${lib.getExe' pkgs.systemd "systemctl"} restart nix-daemon
      }

      disable_cache() {
        if [[ -f "$CONF" ]]; then
          rm -f "$CONF"
          ${lib.getExe' pkgs.systemd "systemctl"} restart nix-daemon
        fi
      }

      if vpn_active; then
        if ! wifi_active || at_home_wifi; then
          enable_cache 10
        else
          enable_cache 99
        fi
      else
        disable_cache
      fi
    '';
  };
}
