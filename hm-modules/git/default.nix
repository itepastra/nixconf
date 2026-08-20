{
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ../../config/info ];

  home.packages = [
    pkgs.git-credential-manager
  ];

  programs.git = {
    enable = true;
    settings = {
      user =
        let
          userinfo = config.modules.info.${config.home.username};
        in
        {
          name = userinfo.name;
          email = userinfo.email;
        };
      init = {
        defaultBranch = "main";
      };
      safe.directory = "/etc/nixos";
      pull.rebase = false;
      commit.gpgsign = true;
      push.autoSetupRemote = true;
      credential.helper = "store";
      credential.credentialStore = "secretservice";
    };
  };

}
