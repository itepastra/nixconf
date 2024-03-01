#version 310 es
precision highp float;

uniform sampler2D tex2D;
uniform sampler2D old2D;
uniform ivec2 resolution;
uniform float frame_part;

in highp vec2 texCoords;
out vec4 stateColor;

const vec4 bgColor = vec4(0.15, 0.02, 0.18, 1.0);
const vec4 fgColor = vec4(0.58, 0.06, 0.68, 1.0);

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
}
