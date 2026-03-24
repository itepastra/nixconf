{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config.programs.nixvim.plugins.conform-nvim = {
    settings = {
      default_format_opts.lsp_format = "fallback";
      format_on_save = ''
        function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end

          return { timeout_ms = 1000, lsp_fallback = true }, on_format
         end
      '';

      format_after_save = ''
        function(bufnr)
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end

          return { lsp_fallback = true }
        end
      '';
      notify_on_error = true;
      formatters_by_ft = {
        html = [ "prettier" ];
        css = [ "prettier" ];
        javascript = [ "prettier" ];
        typescript = [ "prettier" ];
        svelte = [ "prettier" ];
        python = [
          "isort"
          "yapf"
        ];
        lua = [ "stylua" ];
        nix = [ "nixfmt" ];
        markdown = [ "prettier" ];
        yaml = [ "prettier" ];
        bicep = [ "bicep" ];
        bash = [
          "shellcheck"
          "shellharden"
          "shfmt"
        ];
        json = [ "jq" ];
        bib = [ "bibtex-tidy" ];
        "_" = [ "trim_whitespace" ];
      };

      formatters = {
        black = {
          command = "${lib.getExe pkgs.black}";
          append_args = [
            "-l"
            "160"
            "-C"
          ];
        };
        isort = {
          command = "${lib.getExe pkgs.isort}";
          append_args = [
            "--line-length"
            "160"
          ];
        };
        yapf = {
          command = "${lib.getExe pkgs.yapf}";
          append_args = [
            "--style"
            "{based_on_style: pep8, column_limit: 160, dedent_closing_brackets: false, coalesce_brackets: false, split_before_named_assigns: false, split_before_closing_bracket: false, align_closing_bracket_with_visual_indent: true}"
          ];
        };
        nixfmt = {
          command = "${lib.getExe pkgs.nixfmt}";
        };
        alejandra = {
          command = "${lib.getExe pkgs.alejandra}";
        };
        jq = {
          command = "${lib.getExe pkgs.jq}";
        };
        bibtex-tidy = {
          command = "${lib.getExe pkgs.bibtex-tidy}";
        };
        prettier =
          # let
          #   pwp = import inputs.prettier-plugins { inherit lib pkgs; };
          #   prettierCustom = pwp.prettier {
          #     enabled = with pwp.plugins; [
          #       prettier-plugin-svelte
          #     ];
          #   };
          # in
          {
            # command = "${lib.getExe prettierCustom}";
            command = "${lib.getExe pkgs.prettier}";
          };
        stylua = {
          command = "${lib.getExe pkgs.stylua}";
        };
        shellcheck = {
          command = "${lib.getExe pkgs.shellcheck}";
        };
        shfmt = {
          command = "${lib.getExe pkgs.shfmt}";
        };
        shellharden = {
          command = "${lib.getExe pkgs.shellharden}";
        };
        bicep = {
          command = "${lib.getExe pkgs.bicep}";
        };
      };
    };
  };
}
