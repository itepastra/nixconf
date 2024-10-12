{ lib, config, pkgs, inputs, nix-colors, ... }:
let
  cfg = config.modules.automapaper;
in
{
  options.modules.automapaper = {
    enable = lib.mkEnableOption "enable automapaper";
    hyprland = lib.mkEnableOption "enable hyprland exec-once integration";
    default-configuration = {
      init = lib.mkOption
        {
          type = lib.types.str;
          description = "the shader executed to get the state for the initialisation, and re-initialisation steps";
          default = ''
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
        };
      state = lib.mkOption {
        type = lib.types.str;
        description = "the shader executed to increment the state to the next generation";
        default = ''
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
      };
      display = lib.mkOption {
        type = lib.types.str;
        description = "the shader executed to display the state to the monitor";
        default = ''
          #version 310 es
          precision
          highp
          float;

          uniform sampler2D tex2D;
          uniform sampler2D old2D;
          uniform ivec2 resolution;
          uniform float frame_part;

          in highp vec2 texCoords;
          out vec4 stateColor;

          const vec4 bgColor = ${nix-colors.lib.conversions.hexToGLSLVec config.colorScheme.palette.background_paper};
          const vec4 fgColor = ${nix-colors.lib.conversions.hexToGLSLVec config.colorScheme.palette.foreground_paper};

          void main() {
            vec2 canvasSize = vec2 (textureSize (tex2D, 0));
            vec4 state = texture (tex2D, texCoords);
            vec4 ostate = texture (old2D, texCoords);

            vec2 localCoords = fract (gl_FragCoord.xy / vec2 (resolution) * canvasSize);
            localCoords = localCoords - 0.5;
            float dist = sqrt (dot (localCoords, localCoords));

            float size = smoothstep (0.0, 1.0, pow(mix(ostate.g,state.g, frame_part), 3.0)) * 0.35;
            float mask = 1.0 - step (size, dist);

            float brightness = mix (ostate.r, state.r, frame_part) + 0.2 * pow(mix(ostate.g,state.g, frame_part), 3.0);
            stateColor = mix (bgColor, fgColor, brightness * mask);
          } '';
      };
      horizontal = lib.mkOption {
        type = lib.types.int;
        default = 10;
      };
      vertical = lib.mkOption {
        type = lib.types.int;
        default = 10;
      };
      tps = lib.mkOption {
        type = lib.types.int;
        description = "the target amount of ticks to simulate each second";
        default = 30;
      };
      cycles = lib.mkOption {
        type = lib.types.int;
        description = "the amount of state increments before the init shader is called again";
        default = 2500;
      };
      frames_per_tick = lib.mkOption {
        type = lib.types.int;
        description = "the amount of times to call the display shader for each iteration of the state shader";
        default = 1;
      };
    };
  };

  config = lib.mkIf cfg.enable
    {
      wayland.windowManager.hyprland.settings.exec-once =
        let
          mkDisplayConfig = conf:
            let
              init = builtins.toFile "init.frag" conf.init;
              state = builtins.toFile "state.frag" conf.state;
              display = builtins.toFile "display.frag" conf.display;
            in
            ''
              [display]
              name="${conf.name}"
              horizontal=${builtins.toString conf.horizontal}
              vertical=${builtins.toString conf.vertical}
              tps=${builtins.toString conf.tps}
              state_frag="${state}"
              init_frag="${init}"
              display_frag="${display}"
              cycles=${builtins.toString conf.cycles}
              frames_per_tick=${builtins.toString conf.frames_per_tick}
            '';
          confFile =
            let
              def = config.modules.automapaper.default-configuration;
            in
            conf: builtins.toFile "${conf.name}.toml" (mkDisplayConfig {
              name = conf.name;
              horizontal = builtins.div conf.horizontal def.horizontal;
              vertical = builtins.div conf.vertical def.vertical;
              tps = def.tps;
              state = def.state;
              init = def.init;
              display = def.display;
              cycles = def.cycles;
              frames_per_tick = def.frames_per_tick;
            });
        in
        lib.mkIf cfg.hyprland (
          builtins.map
            (
              conf:
              "${inputs.automapaper.packages.${pkgs.system}.default}/bin/automapaper -C ${confFile conf}"
            )
            config.modules.hyprland.displays
        );
    };
}

