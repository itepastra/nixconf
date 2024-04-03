lib: name:
{
  left = lib.mkOption {
    type = with lib.types; listOf (enum [ name ]);
  };
  center = lib.mkOption {
    type = with lib.types; listOf (enum [ name ]);
  };
  right = lib.mkOption {
    type = with lib.types; listOf (enum [ name ]);
  };
}
