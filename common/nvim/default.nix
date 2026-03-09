{
  pkgs,
  lib,
  config,
  ...
}:
let
  helpers = config.lib.nixvim;
in
{
  imports = [
    ./plugins
  ];
  config = {

    programs.nixvim = {
      enable = true;
      enableMan = true;
      enablePrintInit = true;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };

      opts = {
        number = true;
        relativenumber = true;
        mouse = "a";
        cursorline = true;
        scrolloff = 5;
        inccommand = "split";
        showmode = false;
        splitright = true;
        splitbelow = true;
      };

      colorschemes.rose-pine = {
        enable = true;
        settings = {
          before_highlight = "function(group, highlight, palette) end";
          dark_variant = "moon";
          dim_inactive_windows = true;
          enable = {
            legacy_highlights = false;
            migrations = true;
            terminal = false;
          };
          extend_background_behind_borders = true;
          groups = {
            border = "muted";
            link = "iris";
            panel = "surface";
          };
          highlight_groups = { };
          styles = {
            bold = false;
            italic = true;
            transparency = true;
          };
          variant = "moon";
        };
      };

      clipboard.providers = {
        wl-copy.enable = true;
      };

      keymaps = [
        {
          action = "<cmd>Ex<cr>";
          key = "<leader>pv";
          mode = "n";
        }
        {
          action = ''"+y'';
          key = "<leader>y";
          mode = [
            "n"
            "v"
          ];
        }
        {
          action = ":m '>+1<CR>gv=gv";
          key = "J";
          mode = "v";
        }
        {
          action = ":m '<-2<CR>gv=gv";
          key = "K";
          mode = "v";
        }
        {
          action = {
            __raw = "vim.diagnostic.setloclist";
          };
          key = "<leader>q";
          mode = "n";
        }
        {
          action = {
            __raw = "vim.diagnostic.open_float";
          };
          key = "<leader>e";
          mode = "n";
        }
      ];

      performance = {
        byteCompileLua = {
          enable = false;
          configs = true;
          initLua = true;
          luaLib = true;
          nvimRuntime = true;
          plugins = true;
        };
      };

      lsp = {
        inlayHints.enable = true;
        keymaps = import ./lsp_keymaps.nix helpers;
        servers = import ./lsp_configs.nix;
      };

      autoCmd = [
        {
          event = "TextYankPost";
          desc = "Highlight when yanking text";
          group = "kickstart-highlight-yank";
          callback = {
            __raw = "function() vim.hl.on_yank() end";
          };
        }
      ];

      autoGroups = {
        kickstart-highlight-yank.clear = true;
      };

      diagnostic.settings = {
        severity_sort = true;
        float = {
          border = "rounded";
          source = "if_many";
        };
        underline = {
          severity = {
            __raw = "vim.diagnostic.severity.ERROR";
          };
        };
        signs = {
          __raw = ''
            vim.g.have_nerd_font and {
                      text = {
                        [vim.diagnostic.severity.ERROR] = '󰅚 ',
                        [vim.diagnostic.severity.WARN] = '󰀪 ',
                        [vim.diagnostic.severity.INFO] = '󰋽 ',
                        [vim.diagnostic.severity.HINT] = '󰌶 ',
                      },
                    } or {}'';
        };
        virtual_text = {
          source = "if_many";
          spacing = 2;
          format = {
            __raw = "function(diagnostic) local diagnostic_message = {[vim.diagnostic.severity.ERROR]=diagnostic.message,[vim.diagnostic.severity.WARN]=diagnostic.message,[vim.diagnostic.severity.INFO]=diagnostic.message,[vim.diagnostic.severity.HINT]=diagnostic.message,} return diagnostic_message[diagnostic.severity] end";
          };
        };
      };
    };

  };
}
