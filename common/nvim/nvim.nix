{  pkgs, lib, ... }:

{
	home.packages = with pkgs; [
		# needed for the nvim config, neovim itself is a system package already
		ripgrep

		# TODO: find how I can make this build dependencies only
		gnumake
		cargo
		rustc
		python3
	];
	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;

		extraLuaConfig = lib.fileContents ./init.lua;
	};
	programs.nixvim = {
		enable = false;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;

		colorschemes.tokyonight = {
			enable = true;
			style = "night";
		};

		globals = {
			mapleader = " ";
			maplocalleader = " ";
		};

		options = {
			hlsearch = true;
			number = true;
			relativenumber = true;
			mouse = "a";
			showmode = false;
			breakindent = true;
			undofile = true;
			ignorecase = true;
			smartcase = true;
			signcolumn = "yes";
			updatetime = 250;
			timeoutlen = 300;
			splitright = true;
			splitbelow = true;

			shiftwidth = 4;
			tabstop = 4;

			list = true;
			listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };

			inccommand = "split";
			cursorline = true;

			scrolloff = 10;
			foldmethod = "expr";
			foldexpr = "nvim_treesitter#foldexpr()";

		};
		autoGroups = {
			"kickstart-highlight-yank" = { clear = true; };
		};

		autoCmd = [
			{
				event = "TextYankPost";
				group = "kickstart-highlight-yank";
				command = ''lua vim.highlight.on_yank()'';
			}
			{
				event = ["BufReadPost" "FileReadPost"];
				command = "normal zR";
			}
		];

		filetype.extension = {
			templ = "templ";
		};

		keymaps = [
			{ mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>";}
			{ mode = "t"; key = "<Esc><Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode" ;}
			{ mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window" ;}
			{ mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window" ;}
			{ mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window" ;}
			{ mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window" ;}
			{ mode = "n"; key = "<leader>pv"; lua = true; action = "vim.cmd.Ex";}
			{ mode = "x"; key = "<leader>p"; action = ''"_dP''; options.desc = "paste without override";}
			{ mode = [ "n" "v" ]; key = "<leader>y"; action = ''"+y''; options.desc = "copy to system clipboard";}
			{ mode = "n"; key = "<leader>Y"; action = ''"+Y''; options.desc = "copy line to system clipboard";}
			{ mode = [ "n" "v" ]; key = "<leader>d"; action = ''"_d''; options.desc = "delete without override";}
			{ mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "move selected down";}
			{ mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "move selected up";}
		];

		plugins = {
			fugitive.enable = true;
			nvim-colorizer.enable = true;
			comment.enable = true;
			gitsigns = {
				enable = true;
				signs = {
					add.text = "+";
					change.text = "~";
					delete.text = "_";
					topdelete.text = "‾";
					changedelete.text = "~";
					untracked.text = "┆";
				};
			};
			which-key = {
				enable = true;
				registrations = {
					"<leader>c" = "[C]ode";
					"<leader>d" = "[D]ocument";
					"<leader>r" = "[R]ename";
					"<leader>s" = "[S]earch";
					"<leader>w" = "[W]orkspace";
				};
			};
			telescope = {
				enable = true;
				extensions = {
					fzf-native.enable = true;
					ui-select.enable = true;
				};
				keymaps = {
					"<leader>sh" = { action = "help_tags"; desc = "[S]earch [H]elp"; };
					"<leader>sk" = { action = "keymaps"; desc = "[S]earch [K]eymaps"; };
					"<leader>sf" = { action = "find_files"; desc = "[S]earch [F]iles"; };
					"<leader>ss" = { action = "builtin"; desc = "[S]earch [S]elect Telescope"; };
					"<leader>sw" = { action = "grep_string"; desc = "[S]earch current [W]ord"; };
					"<leader>sg" = { action = "live_grep"; desc = "[S]earch by [G]rep"; };
					"<leader>sd" = { action = "diagnostics"; desc = "[S]earch [D]iagnostics"; };
					"<leader>sr" = { action = "resume"; desc = "[S]earch [R]esume"; };
					"<leader>s." = { action = "oldfiles"; desc = ''[S]earch Recent Files ("." for repeat)''; };
					"<leader><leader>" = { action = "buffers"; desc = "[ ] Find existing buffers"; };
				};
			};
			conform-nvim = {
				enable = true;
				formatOnSave = {
					timeoutMs = 500;
					lspFallback = true;
				};
				formattersByFt = {
					lua = [ "stylua" ];
					python = [ "black" ];
					yaml = [ "yamlls" ];
				};
			};
			cmp = {
				enable = true;
				# TODO: find out how cmp works
			};
			todo-comments = {
				enable = true;
				signs = false;
			};
			mini = {
				enable = true;
				modules = {
					ai = {
						n_lines = 500;
					};
					surround = {};
					statusline = {};
				};
			};
			treesitter = {
				enable = true;
				indent = true;
				folding = true;
				nixvimInjections = true;
				ignoreInstall = [
					"comment"
				];
			};
			treesitter-context = {
				enable = true;
				maxLines = 8;
			};
			fidget.enable = true;
			lsp = {
				enable = true;
				# TODO: use onAttach instead of the autocmd
				onAttach = ''
  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
  end
  map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
  map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
  map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
  map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  map(
    "<leader>ws",
    require("telescope.builtin").lsp_dynamic_workspace_symbols,
    "[W]orkspace [S]ymbols"
  )
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client.server_capabilities.documentHighlightProvider then
  vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
    buffer = event.buf,
    callback = vim.lsp.buf.document_highlight,
  })
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    buffer = event.buf,
    callback = vim.lsp.buf.clear_references,
  })
  end
				'';
				# NOTE: there can also be keymaps for lsp apparently

				keymaps = {
					diagnostic = {
						"[d" = "goto_prev";
						"]d" = "goto_next";
						"<leader>e" = "open_float";
						"<leader>q" = "setloclist";
					};
					lspBuf = {
						"K" = "hover";
						"<leader>rn" = "rename";
						"<leader>ca" = "code_action";
						"gD" = "declaration";
					};
				};

				servers = {
					gopls.enable = true;
					htmx.enable = true;
					lua-ls.enable = true;
					nil_ls.enable = true;
					pylsp.enable = true;
					rust-analyzer = {
						enable = true;
						installRustc = false;
						installCargo = false;
					};
					yamlls.enable = true;
				};
			};
			lsp-format = {
				enable = true;
			};
		};
		extraPlugins = with pkgs.vimPlugins; [
			vim-sleuth
			neodev-nvim
		];
	};
}
