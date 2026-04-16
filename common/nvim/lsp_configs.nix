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
  rust_analyzer = {
    enable = true;
    packageFallback = true;
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
