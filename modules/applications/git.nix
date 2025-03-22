{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.apps.git;
in
{
  options.modules.apps.git = {
    enable = lib.mkEnableOption "enable git";
    name = lib.mkOption {
      example = "Jill Doe";
      description = "the git user Name";
      type = lib.types.str;
    };
    email = lib.mkOption {
      example = "jilldoe@test.local";
      description = "the git user Name";
      type = lib.types.str;
    };
    do_sign = lib.mkEnableOption "enable commit signing";
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.name;
      userEmail = cfg.email;
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        safe.directory = "/etc/nixos";
        pull.rebase = false;
        commit.gpgsign = cfg.do_sign;
        push.autoSetupRemote = true;
      };
    };
  };

}
