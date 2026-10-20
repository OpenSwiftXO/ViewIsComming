#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 split(float2 position,
            SwiftUI::Layer layer,
            float2 size,
            float progress,
            float smoothness,
            float isHorizontal,
            float isOpen) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Choose axis based on isHorizontal
    // Horizontal: splits top/bottom (uses uv.y)
    // Vertical: splits left/right (uses uv.x)
    float coord = isHorizontal > 0.5 ? uv.y : uv.x;
    // Calculate distance from center (0.0 at center, 1.0 at edges)
    float centerDist = abs(coord - 0.5) * 2.0;
    // For close mode: use distance from edges instead (0.0 at edges, 1.0 at center)
    float dist = isOpen > 0.5 ? centerDist : (1.0 - centerDist);
    // Scale progress to account for smoothness
    // When progress=0: scaled=-smoothness (all hidden)
    // When progress=1: scaled=1+smoothness (all visible)
    float scaledProgress = progress * (1.0 + 2.0 * smoothness) - smoothness;
    // smoothstep creates smooth edge transition
    float edge = smoothstep(scaledProgress - smoothness, scaledProgress + smoothness, dist);
    // Mask: reveals as progress increases (1 - edge)
    float mask = 1.0 - edge;
    // Sample color
    half4 color = layer.sample(position);
    return color * half(mask);
}
