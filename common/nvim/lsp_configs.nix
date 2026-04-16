{
  "*" = {
    config = {
      capabilities = {
        textDocument = {
          semanticTokens = {
            multilineTokenSupport = true;
          };
        };
      };
      root_markers = [
        ".git"
      ];
    };
  };

  clangd = {
    enable = true;
  };
  lua_ls = {
    enable = true;
  };
  html = {
    enable = true;
  };
  nil_ls = {
    enable = true;
  };
  basedpyright = {
    enable = false;
  };
  ty = {
    enable = true;
  };
  gopls = {
    enable = true;
  };
  rust-analyzer = {
    enable = true;
  };
  jsonls = {
    enable = true;
  };
  typst = {
    enable = true;
  };
  csharp_ls = {
    enable = true;
  };
}
