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
}
