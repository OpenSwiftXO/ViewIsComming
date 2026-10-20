#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 cornerVanish(float2 position,
                   SwiftUI::Layer layer,
                   float2 size,
                   float progress,
                   float smoothness,
                   float cornerFloat) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Cast float to int for corner selection
    int corner = int(cornerFloat);
    // Determine corner origin (0=TL, 1=TR, 2=BR, 3=BL)
    float2 cornerOrigin;
    if (corner == 0) {
        cornerOrigin = float2(0.0, 0.0);
    } else if (corner == 1) {
        cornerOrigin = float2(1.0, 0.0);
    } else if (corner == 2) {
        cornerOrigin = float2(1.0, 1.0);
    } else {
        cornerOrigin = float2(0.0, 1.0);
    }
    // Calculate distance from corner
    float dist = length(uv - cornerOrigin);
    // Maximum distance (diagonal)
    float maxDist = sqrt(2.0);
    // Calculate reveal threshold with smoothness factor
    float threshold = progress * maxDist * (1.0 + smoothness);
    // Create mask based on distance
    float mask = 1.0 - smoothstep(threshold - smoothness, threshold, dist);
    
    half4 color = layer.sample(position);
    return color * half(mask);
}
