{ config, pkgs, inputs, ... }:

{
	home.packages = with pkgs; [
		# needed for the nvim config, neovim itself is a system package already
		ripgrep
	];
	# programs.neovim = {
	# 	enable = true;
	# 	defaultEditor = true;
	#
	# 	viAlias = true;
	# 	vimAlias = true;
	# 	vimdiffAlias = true;
	#
	# 	extraLuaConfig = ''
	# 		${builtins.readFile ./init.lua}
	# 	'';
	# };
	programs.nixvim = {
		enable = true;
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

			list = true;
			listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };

			inccommand = "split";
			cursorline = true;

			scrolloff = 10;
			foldmethod = "expr";
			foldexpr = "nvim_treesitter#foldexpr()";

			autoGroups = {
				"kickstart-highlight-yank" = { clear = true; };
				"kickstart-lsp-attach" = {clear = true; };
			};

			autoCmd = [
				{
					event = "TextYankPost";
					group = "kickstart-highlight-yank";
					callback = ''function() vim.highlight.on_yank() end'';
				}
				{
					event = "LspAttach";
					group = "kickstart-lsp-attach";
					callback = builtins.readFile ./lsp_autocmd.lua;
				}
			];
		};

		keymaps = [
			{ mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>";}
			{ mode = "n"; key = "[d"; lua = true; action = "vim.diagnostic.goto_prev"; options.desc = "Go to previous [D]iagnostic message" ;}
			{ mode = "n"; key = "]d"; lua = true; action = "vim.diagnostic.goto_next"; options.desc = "Go to next [D]iagnostic message" ;}
			{ mode = "n"; key = "<leader>e"; lua = true; action = "vim.diagnostic.open_float"; options.desc = "Show diagnostic [E]rror messages" ;}
			{ mode = "n"; key = "<leader>q"; lua = true; action = "vim.diagnostic.setloclist"; options.desc = "Open diagnostic [Q]uickfix list" ;}
			{ mode = "t"; key = "<Esc><Esc>"; action = "<C-\\><C-n>"; options.desc = "Exit terminal mode" ;}
			{ mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window" ;}
			{ mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window" ;}
			{ mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window" ;}
			{ mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window" ;}
			{ mode = "n"; key = "<leader>pv"; lua = true; action = "vim.cmd.Ex";}
			{ mode = "x"; key = "<leader>p"; action = ''[["_dP]]'';}
			{ mode = [ "n" "v" ]; key = "<leader>y"; action = ''[["+y]]'';}
			{ mode = "n"; key = "<leader>Y"; action = ''[["+Y]]'';}
			{ mode = [ "n" "v" ]; key = "<leader>d"; action = ''[["_d]]'';}
			{ mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv";}
			{ mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv";}
		];

		plugins = {
			fugitive.enable = true;
			nvim-colorizer.enable = true;
			comment-nvim.enable = true;
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
					"<leader>sh" = {
						action = "help_tags";
						desc = "[S]earch [H]elp";
					};
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
			};
			treesitter-context = {
				enable = true;
				maxLines = 8;
			};
		};
		extraPlugins = with pkgs.vimPlugins; [
			vim-sleuth
		];
	};
}
