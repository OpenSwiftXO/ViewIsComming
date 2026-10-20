#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 directionalWipe(float2 position,
                      SwiftUI::Layer layer,
                      float2 size,
                      float progress,
                      float2 direction,
                      float smoothness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    const float2 center = float2(0.5, 0.5);
    // Normalize direction
    float2 v = normalize(direction);
    v /= abs(v.x) + abs(v.y);
    float d = v.x * center.x + v.y * center.y;
    // Calculate mask (m = 0 when hidden, m = 1 when visible)
    float m = (1.0 - step(progress, 0.0)) * (1.0 - smoothstep(-smoothness, 0.0, v.x * uv.x + v.y * uv.y - (d - 0.5 + progress * (1.0 + smoothness))));
    
    // Sample color
    half4 color = layer.sample(position);
    return color * half(m);
}
