#version 450

layout(location = 0) in vec2 v_uv;
layout(location = 0) out vec4 out_color;

layout(set = 0, binding = 0) uniform Params {
    vec2 resolution;
    float time;
    float time_scale;
    vec4 c1;
    vec4 c2;
    vec4 c3;
    vec4 c4;
    vec2 mouse;
    float mouse_active;
    float extra;
} ubo;

layout(set = 0, binding = 1) uniform texture2D state_tex;
layout(set = 0, binding = 2) uniform sampler state_sampler;

void main() {
    vec4 state = texture(sampler2D(state_tex, state_sampler), v_uv);

    vec2 canvasSize = vec2(textureSize(state_tex, 0));

    vec2 localCoords = fract(gl_FragCoord.xy / ubo.resolution * canvasSize);
    localCoords = localCoords - 0.5;

    float dist = sqrt(dot(localCoords, localCoords));

    float size = smoothstep(0.0, 1.0, pow(state.g, 3.0)) * 0.35;
    float mask = 1.0 - step(size, dist);

    float brightness = state.r + 0.2 * pow(state.g, 3.0);

    out_color = mix(ubo.c1, ubo.c2, brightness * mask);
}

