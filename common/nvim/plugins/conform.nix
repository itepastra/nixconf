{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  config.programs.nixvim.plugins.conform-nvim = {
    settings = {
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
          "black"
          "isort"
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
        "_" = [ "trim_whitespace" ];
      };

      formatters = {
        black = {
          command = "${lib.getExe pkgs.black}";
        };
        isort = {
          command = "${lib.getExe pkgs.isort}";
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
        prettier =
          let
            pwp = import inputs.prettier-plugins { inherit lib pkgs; };
            prettierCustom = pwp.prettier {
              enabled = with pwp.plugins; [
                prettier-plugin-svelte
              ];
            };
          in
          {
            command = "${lib.getExe prettierCustom}";
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
