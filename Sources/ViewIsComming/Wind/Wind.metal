#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 wind(float2 position,
           SwiftUI::Layer layer,
           float2 size,
           float progress,
           float windSize,
           float direction) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize pixel coordinates to [0,1] range
    float2 uv = position / size;
    // smoothstep() needs edge0 < edge1.
    windSize = max(windSize, 0.0001);
    // Determine primary coordinate based on wind direction
    // coord: position along the wind direction (0.0 to 1.0)
    // perpendicular: position perpendicular to wind (for random seed)
    float coord;
    float perpendicular;
    int dir = int(direction);
    if (dir == 0) {
        // Left to Right: reveal from left (x=0) to right (x=1)
        coord = uv.x;
        perpendicular = uv.y;
    } else if (dir == 1) {
        // Right to Left: reveal from right to left
        coord = 1.0 - uv.x;
        perpendicular = uv.y;
    } else if (dir == 2) {
        // Top to Bottom: reveal from top (y=0) to bottom (y=1)
        coord = uv.y;
        perpendicular = uv.x;
    } else {
        // Bottom to Top: reveal from bottom to top
        coord = 1.0 - uv.y;
        perpendicular = uv.x;
    }
    // Generate pseudo-random value [0,1] for this pixel
    // Uses perpendicular coordinate as seed for variation across wind direction
    float randomOffset = fract(sin(perpendicular * 12.9898 + 78.233) * 43758.5453);
    // Calculate reveal threshold for this pixel
    // - Base threshold: coord * (1.0 - windSize) spreads reveals across [0, 1-windSize]
    // - Random offset: windSize * randomOffset adds turbulence [0, windSize]
    // Result: each pixel has unique reveal time with natural variation
    float revealThreshold = coord * (1.0 - windSize) + windSize * randomOffset;
    // Calculate visibility mask
    // - progress * (1.0 + windSize): extends progress range to ensure full reveal
    // - smoothstep: creates soft edge transition around threshold
    // - When progress < revealThreshold: mask ≈ 0 (hidden)
    // - When progress > revealThreshold: mask ≈ 1 (visible)
    // front runs over [-windSize, 1 + windSize] so every pixel is hidden at
    // progress 0 and fully visible at progress 1.
    float front = mix(-windSize, 1.0 + windSize, progress);
    float mask = smoothstep(revealThreshold - windSize, revealThreshold + windSize, front);
    // Sample pixel color and apply visibility mask
    half4 color = layer.sample(position);
    return color * half(mask);
}
