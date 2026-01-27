{ mkRaw, ... }:
[
  {
    key = "gd";
    lspBufAction = "definition";
    mode = "n";
  }
  {
    key = "gD";
    lspBufAction = "references";
    mode = "n";
  }
  {
    key = "gt";
    lspBufAction = "type_definition";
    mode = "n";
  }
  {
    key = "gi";
    lspBufAction = "implementation";
    mode = "n";
  }
  {
    key = "K";
    lspBufAction = "hover";
    mode = "n";
  }
  {
    action = mkRaw "require('telescope.builtin').lsp_definitions";
    key = "gd";
  }
]
