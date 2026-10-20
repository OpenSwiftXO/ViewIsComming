#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

float randomNoise_rand(float2 co) {
    return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

[[ stitchable ]]
half4 randomNoise(float2 position,
                  SwiftUI::Layer layer,
                  float2 size,
                  float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Sample color
    half4 color = layer.sample(position);
    // Generate random noise based on position
    float noise = randomNoise_rand(uv);
    // Random pixels appear gradually
    float mask = floor(noise + progress);
    return color * half(mask);
}
