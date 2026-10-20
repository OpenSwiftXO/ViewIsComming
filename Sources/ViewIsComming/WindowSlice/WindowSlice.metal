#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 windowSlice(float2 position,
                  SwiftUI::Layer layer,
                  float2 size,
                  float progress,
                  float count,
                  float smoothness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    float pr = smoothstep(-smoothness, 0.0, uv.x - progress * (1.0 + smoothness));
    float s = step(pr, fract(count * uv.x));
    // Calculate mask
    float mask = s;
    // Sample and apply mask
    half4 color = layer.sample(position);
    return color * half(mask);
}
