config:
builtins.map
  (n: { name = n; value = { enable = true; }; })
  (import ./allmodules.nix config)
