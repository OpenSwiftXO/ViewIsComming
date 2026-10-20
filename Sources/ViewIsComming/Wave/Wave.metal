#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 wave(float2 position,
           SwiftUI::Layer layer,
           float2 size,
           float progress,
           float amplitude,
           float waves) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Calculate wave distortion
    float waveOffset = sin(uv.y * waves * M_PI_F * 2.0 + progress * M_PI_F) * amplitude * (1.0 - progress);
    // Apply wave to x coordinate
    float2 displaced = uv;
    displaced.x += waveOffset;
    // Sample with displacement
    float2 samplePos = displaced * size;
    half4 color = layer.sample(samplePos);
    // Apply mask based on progress
    float mask = progress;
    return color * half(mask);
}
