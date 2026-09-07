{
  btop,
}:
btop.overrideAttrs (oldAttrs: {
  patches = (oldAttrs.patches or [ ]) ++ [ ./btop-no-nix-store.patch ];
})
