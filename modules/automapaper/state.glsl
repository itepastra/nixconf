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

vec4 get(int x, int y) {
    vec2 scale = vec2(textureSize(state_tex, 0));
    vec2 uv = (gl_FragCoord.xy + vec2(x, y)) / scale;
    return texture(sampler2D(state_tex, state_sampler), uv);
}

void main() {
    int sum = int(
        get(-1, -1).r +
        get(-1,  0).r +
        get(-1,  1).r +
        get( 0, -1).r +
        get( 0,  1).r +
        get( 1, -1).r +
        get( 1,  0).r +
        get( 1,  1).r
    );

    vec4 current = get(0, 0);

    if (sum == 3) {
        out_color = vec4(1.0, 1.0, 0.0, 1.0);
    } else if (sum == 2) {
        out_color = current;
        if (current.r == 0.0) {
            out_color.g = max(current.g - 0.01, 0.0);
        }
    } else {
        out_color = vec4(0.0, max(current.g - 0.01, 0.0), 0.0, 1.0);
    }

    if (mouse_active > 0.5) {
        vec2 difference = v_uv - mouse;
        float len2 = dot(difference, difference);
        if (len2 < 0.0001) {
            out_color.r = 1.0;
        }
    }
}

