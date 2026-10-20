#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

float perlin_random(float2 co, float seed) {
    float a = seed;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy, float2(a, b));
    float sn = fmod(dt, 3.14);
    return fract(sin(sn) * c);
}

float perlin_noise(float2 st, float seed) {
    float2 i = floor(st);
    float2 f = fract(st);
    // Four corners in 2D of a tile
    float a = perlin_random(i, seed);
    float b = perlin_random(i + float2(1.0, 0.0), seed);
    float c = perlin_random(i + float2(0.0, 1.0), seed);
    float d = perlin_random(i + float2(1.0, 1.0), seed);
    // Smooth Interpolation
    float2 u = f * f * (3.0 - 2.0 * f);
    // Mix 4 corners percentages
    return mix(a, b, u.x) +
    (c - a) * u.y * (1.0 - u.x) +
    (d - b) * u.x * u.y;
}

[[ stitchable ]]
half4 perlin(float2 position,
             SwiftUI::Layer layer,
             float2 size,
             float progress,
             float scale,
             float smoothness,
             float seed) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Calculate noise
    float n = perlin_noise(uv * scale, seed);
    // Calculate threshold range
    float p = mix(-smoothness, 1.0 + smoothness, progress);
    float lower = p - smoothness;
    float higher = p + smoothness;
    // q is the smoothstep between lower and higher at position n
    float q = smoothstep(lower, higher, n);
    float mask = 1.0 - q;
    // Sample and apply mask
    half4 color = layer.sample(position);
    return color * half(mask);
}
