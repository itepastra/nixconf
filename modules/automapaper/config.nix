{
  writeTextFile,
  display,
  init-shader,
  state-shader,
  display-shader,
  horizontal,
  vertical,
  tps ? 30,
  cycles ? horizontal,
  frames_per_tick ? 1,
}:
writeTextFile {
  name = "automapaper-config-${display}";
  text = ''
    [display]
    name="${display}"
    horizontal=${builtins.toString horizontal}
    vertical=${builtins.toString vertical}
    tps=${builtins.toString tps}
    state_frag="${state-shader}"
    init_frag="${init-shader}"
    display_frag="${display-shader}"
    cycles=${builtins.toString cycles}
    frames_per_tick=${builtins.toString frames_per_tick}
  '';
  destination = "/config.toml";
}
