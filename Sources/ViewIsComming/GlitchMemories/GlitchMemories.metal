#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 glitchMemories(float2 position,
                     SwiftUI::Layer layer,
                     float2 size,
                     float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Calculate block-based noise for glitch effect
    float2 block = floor(uv * float2(16.0));
    float2 uv_noise = block / float2(64.0);
    uv_noise += floor(float2(progress) * float2(1200.0, 3500.0)) / float2(64.0);
    // Distortion decreases as transition progresses (inverted for appearing view)
    // For appearing view: max distortion at progress=0, no distortion at progress=1
    float2 dist = progress < 1.0 ? (fract(uv_noise) - 0.5) * 0.3 * (1.0 - progress) : float2(0.0);
    // RGB chromatic aberration - different distortion for each channel
    float2 red = uv + dist * 0.2;
    float2 green = uv + dist * 0.3;
    float2 blue = uv + dist * 0.5;
    // Sample each color channel with different distortion
    half4 colorRed = layer.sample(red * size);
    half4 colorGreen = layer.sample(green * size);
    half4 colorBlue = layer.sample(blue * size);
    // Combine RGB channels with chromatic aberration
    half4 result = half4(colorRed.r, colorGreen.g, colorBlue.b, 1.0);
    // Apply progressive reveal mask
    // Smooth fade in as progress goes from 0 to 1
    return result * half(progress);
}
