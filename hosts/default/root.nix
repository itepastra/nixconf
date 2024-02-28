{ config, pkgs, inputs, ... }:


{
  imports =
  [
      inputs.nixvim.homeManagerModules.nixvim
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "root";
  home.homeDirectory = "/root";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  nixpkgs.config.allowUnfree = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/noa/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    TERM = "kitty";
  };

  xdg.userDirs.enable = true;
  xdg.userDirs.createDirectories = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # TODO move to seperate file
  programs.zsh = {
	enable=true;
	shellAliases = {
	  ll = "lsd -l";
	  update = "sudo nixos-rebuild switch --flake /etc/nixos#default";
	};
	history = {
		path = "${config.xdg.dataHome}/zsh/history";
		size = 10000;
	};
	oh-my-zsh = {
		enable = true;
		plugins = [ "git" ];
		theme = "frisk";
	};
  };

  # TODO extend and move to seperate file
  programs.git = {
	enable = true;
	userName = "Noa Aarts";
	userEmail = "itepastra@gmail.com";
	extraConfig = {
		init = { defaultBranch = "main"; };
	};
  };

  # TODO move to seperate file
  # TODO create neovim config
  programs.nixvim = {
    enable = true;
    vimAlias = true;

    # Configure neovim options...
    options = {
      relativenumber = true;
      incsearch = true;
    };

    # ...mappings...
    keymaps = [
    	{
		mode = "n";
		key = "<C-s>";
		action = ":w<CR>";
	}
	{
		mode = "n";
		key = "<esc>";
		action = ":noh<CR>";
		options.silent = true;
	}
	{
		mode = "v";
		key = ">";
		action = ">gv";
	}
	{
		mode = "v";
		key = "<";
		action = "<gv";
	}
    ];

    plugins = {

      lsp = {
        keymaps = {
          silent = true;
          diagnostic = {
            "<leader>k" = "goto_prev";
            "<leader>j" = "goto_next";
          };

          lspBuf = {
            gd = "definition";
            K = "hover";
          };
        };
      };
    };

    # ... and even highlights and autocommands !
    highlight.ExtraWhitespace.bg = "red";
    match.ExtraWhitespace = "\\s\\+$";
    autoCmd = [
      {
        event = "FileType";
        pattern = "nix";
        command = "setlocal tabstop=2 shiftwidth=2";
      }
    ];
  };
}
