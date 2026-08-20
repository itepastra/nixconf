{
  lib,
  ...
}:
{
  options.modules.info =
    let
      userdata = lib.types.submodule {
        options = {
          email = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          name = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          ssh-keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          password = lib.mkOption {
            type = lib.types.str;
            default = "!";
          };
        };
      };
    in
    lib.mkOption {
      type = lib.types.attrsOf userdata;
    };

  config.modules.info = {
    noa = {
      email = "noa@voorwaarts.nl";
      name = "Noa Aarts";
      ssh-keys = import ./ssh-keys.nix;
      password = "$6$rounds=512400$Zip3xoK2zcoR4qEL$N13YTHO5tpWfx2nKb1sye.ZPwfoRtMQ5f3YrMZqKzzoFoSSHHJ.l5ulCEa9HygFxZmBtPnwlseFEtl8ERnwF50";
    };
  };
}
