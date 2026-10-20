#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// GlitchDisplace transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/GlitchDisplace.glsl
// Author: Matt DesLauriers
// License: MIT

float glitchDisplace_noise(float2 co) {
    return fract(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
}

[[ stitchable ]] half4 glitchDisplace(float2 position,
                                      SwiftUI::Layer layer,
                                      float2 size,
                                      float progress,
                                      float intensity,
                                      float frequency) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    // Block-based per-tile random displacement.
    float blockSize = max(frequency, 1.0);
    float2 block = floor(uv * blockSize);
    float2 uvNoise = block / blockSize;
    uvNoise += floor(float2(progress * 1200.0, progress * 3500.0)) / blockSize;

    float2 dist = (fract(uvNoise) - 0.5) * 0.3 * (1.0 - progress) * intensity;
    float2 sampleUV = fract(uv + dist);

    // Channel split on strong jitters for extra glitch flavour.
    float strength = length(dist);
    half4 color;
    if (strength > 0.05) {
        float offset = strength * 0.15;
        color.r = layer.sample(fract(sampleUV + float2(offset, 0.0)) * size).r;
        color.g = layer.sample(sampleUV * size).g;
        color.b = layer.sample(fract(sampleUV - float2(offset, 0.0)) * size).b;
        color.a = 1.0;
    } else {
        color = layer.sample(sampleUV * size);
    }

    return color * half(progress);
}
