{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.modules.info =
    let
      userdata = lib.types.submodule {
        email = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        name = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };
    in
    lib.mkOption {
      type = lib.types.attrsOf userdata;
    };

  config = {
    modules.info = {
      root = { };
      noa = {
        email = "noa@voorwaarts.nl";
        name = "Noa Aarts";
      };
    };
    users = lib.mkMerge [
      ({
        users = (
          lib.mapAttrs (user: { name, ... }: {
            description = lib.mkIf (name != "") name;
          }) config.modules.info
        );
      })
      {
        defaultUserShell = pkgs.zsh;
        users = {
          root = lib.mkIf (config.modules.info ? root) {
            hashedPassword = "!";
          };
          noa = lib.mkIf (config.modules.info ? noa) {
            isNormalUser = true;
            extraGroups = [
              "networkmanager"
              "wheel"
              "docker"
              "wireshark"
              "dialout"
            ];
            hashedPassword = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
            openssh.authorizedKeys.keys = (import ./ssh-keys.nix);
          };
        };
      }
    ];
  };
}
