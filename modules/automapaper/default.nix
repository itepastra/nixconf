{ lib, config, pkgs, inputs, nix-colors, ... }:
let
  cfg = config.modules.automapaper;
in
{
  options.modules.automapaper = {
    enable = lib.mkEnableOption "enable automapaper";
    hyprland = lib.mkEnableOption "enable hyprland exec-once integration";
    configurations = lib.mkOption {
      description = "automapaper configurations per monitor";
      type = with lib.types; attrsOf (submodule {
        options = {
          init = lib.mkOption {
            type = str;
            description = "the shader executed to get the state for the initialisation, and re-initialisation steps";
          };
          state = lib.mkOption {
            type = str;
            description = "the shader executed to increment the state to the next generation";
          };
          display = lib.mkOption {
            type = str;
            description = "the shader executed to display the state to the monitor";
          };
          horizontal = lib.mkOption {
            type = int;
            description = "the amount of horizontal cells in the state";
          };
          vertical = lib.mkOption {
            type = int;
            description = "the amount of vertical cells in the state";
          };
          tps = lib.mkOption {
            type = int;
            description = "the target amount of ticks to simulate each second";
          };
          cycles = lib.mkOption {
            type = int;
            description = "the amount of state increments before the init shader is called again";
          };
          frames_per_tick = lib.mkOption {
            type = int;
            description = "the amount of times to call the display shader for each iteration of the state shader";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable (
    let
      displays = lib.attrsets.mapAttrs
        (displayName: displayConfig:
          let
            init = builtins.toFile "init.frag" displayConfig.init;
            state = builtins.toFile "state.frag" displayConfig.state;
            display = builtins.toFile "display.frag" displayConfig.display;
          in
          ''
            [display]
            name="${displayName}"
            horizontal=${builtins.toString displayConfig.horizontal}
            vertical=${builtins.toString displayConfig.vertical}
            tps=${builtins.toString displayConfig.tps}
            state_frag="${state}"
            init_frag="${init}"
            display_frag="${display}"
            cycles=${builtins.toString displayConfig.cycles}
            frames_per_tick=${builtins.toString displayConfig.frames_per_tick}
          ''
        )
        cfg.configurations;
    in
    {
      modules.automapaper.configurations =
        let
          conf = {
            horizontal = 256;
            vertical = 144;
            tps = 30;
            init = ''
              #version 310 es
              precision highp float;

              uniform float time;
              uniform vec2 resolution;

              out vec4 stateColor;

              float PHI = 1.61803398874989484820459;  // Φ = Golden Ratio   

              float gold_noise(in vec2 xy, in float seed){
               return fract(tan(distance(xy*PHI, xy)*seed)*xy.x);
              }

              void main( void ) {

              vec2 position = gl_FragCoord.xy;
              float color = gold_noise(position.xy, fract(time));


              stateColor = vec4(step(0.3, color), 0,0,step(0.3, color));
              }'';
            state = ''
              #version 310 es
              precision highp float;

              uniform sampler2D state;
              uniform vec2 scale;

              out vec4 stateColor;

              vec4 get(int x, int y) {
              return texture(state, (gl_FragCoord.xy + vec2(x, y)) / scale);
              }

              void main() {
              int sum = int(get(-1, -1).r +
              get(-1,  0).r +
              get(-1,  1).r +
              get( 0, -1).r +
              get( 0,  1).r +
              get( 1, -1).r +
              get( 1,  0).r +
              get( 1,  1).r);
              vec4 current = get(0,0);
              if (sum == 3) {
              stateColor.r = 1.0;
              stateColor.g = 1.0;
              } else if (sum == 2) {
              stateColor = current;
              if (current.r == 0.0) {
              stateColor.g = max(current.g - 0.01, 0.0);
              }
              } else {
              stateColor = vec4(0.0, max(current.g - 0.01, 0.0), 0.0, 1.0);
              }

              }'';
            display = ''
              #version 310 es
              precision highp float;

              uniform sampler2D tex2D;
              uniform sampler2D old2D;
              uniform ivec2 resolution;
              uniform float frame_part;

              in highp vec2 texCoords;
              out vec4 stateColor;

              const vec4 bgColor = ${nix-colors.lib.conversions.hexToGLSLVec config.colorScheme.palette.base00}; // #26052e
              const vec4 fgColor = ${nix-colors.lib.conversions.hexToGLSLVec config.colorScheme.palette.base01}; // #950fad

              void main() {
              vec2 canvasSize = vec2(textureSize(tex2D, 0));
              vec4 state = texture(tex2D, texCoords);
              vec4 ostate = texture(old2D, texCoords);

              vec2 localCoords = fract(gl_FragCoord.xy / vec2(resolution) * canvasSize);
              localCoords = localCoords - 0.5;
              float dist = sqrt(dot(localCoords, localCoords));

              float size = smoothstep(0.0, 1.0, pow(mix(ostate.g,state.g, frame_part), 3.0)) * 0.35;
              float mask = 1.0 - step(size, dist);

              float brightness = mix(ostate.r,state.r, frame_part) + 0.2 * pow(mix(ostate.g,state.g, frame_part), 3.0);
              stateColor = mix(bgColor, fgColor, brightness * mask);
              }'';
            cycles = 2500;
            frames_per_tick = 1;
          };
        in
        {
          "DP-3" = conf;
          "DP-2" = conf;
        };
      wayland.windowManager.hyprland.settings.exec-once = lib.mkIf cfg.hyprland (
        lib.mapAttrsToList
          (name: config:
            "${inputs.automapaper.packages.${pkgs.system}.default}/bin/automapaper -C ${builtins.toFile "${name}.toml" config}")
          displays
      );
    }
  );
}
