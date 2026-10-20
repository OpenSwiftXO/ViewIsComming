#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 luma(float2 position,
           SwiftUI::Layer layer,
           float2 size,
           float progress,
           float patternScale) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    // Center the coordinates
    float2 centered = uv - 0.5;
    // Calculate angle and distance from center
    float angle = atan2(centered.y, centered.x);
    float dist = length(centered);
    // Create spiral pattern
    // Normalize angle to [0, 1] range
    float normalizedAngle = (angle + M_PI_F) / (2.0 * M_PI_F);
    // Combine angle and distance to create spiral
    float spiral = fmod(normalizedAngle + dist * patternScale, 1.0);
    // Compare spiral value with progress to determine visibility
    // step returns 1.0 if progress >= spiral, 0.0 otherwise
    float mask = step(spiral, progress);
    // Sample the layer and apply mask
    half4 color = layer.sample(position);
    return color * half(mask);
}
