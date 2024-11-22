#version 310 es
precision highp float;

uniform float time;
uniform vec2 resolution;

out vec4 stateColor;

uint xxhash32(uvec2 p)
{
    const uint PRIME32_2 = 2246822519U, PRIME32_3 = 3266489917U;
    const uint PRIME32_4 = 668265263U, PRIME32_5 = 374761393U;
    uint h32 = p.y + PRIME32_5 + p.x * PRIME32_3;
    h32 = PRIME32_4 * ((h32 << 17) | (h32 >> (32 - 17)));
    h32 = PRIME32_2 * (h32 ^ (h32 >> 15));
    h32 = PRIME32_3 * (h32 ^ (h32 >> 13));
    return h32 ^ (h32 >> 16);
}

void main(void) {
    vec2 position = gl_FragCoord.xy;
    position += 100.0 * time;
    uint hash = xxhash32(uvec2(position.x, position.y));
    float value = float(hash) * (1.0 / float(0xffffffffu));
    stateColor = vec4(step(0.3, value), 0, 0, step(0.3, value));
}
