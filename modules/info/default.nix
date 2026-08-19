{
  lib,
  ...
}:
{
  options.modules.info = {
    email = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
}
