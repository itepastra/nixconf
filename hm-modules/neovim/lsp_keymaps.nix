{ mkRaw, ... }:
[
  {
    key = "gd";
    lspBufAction = "definition";
    mode = "n";
  }
  {
    key = "gr";
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
    key = "<leader>ca";
    lspBufAction = "code_action";
    mode = [
      "n"
      "x"
    ];
  }
  {
    key = "<leader>rn";
    lspBufAction = "rename";
  }
  {
    action = mkRaw "require('telescope.builtin').lsp_definitions";
    key = "gd";
  }
]
