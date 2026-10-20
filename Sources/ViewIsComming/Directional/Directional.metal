#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 directional(float2 position,
                  SwiftUI::Layer layer,
                  float2 size,
                  float progress,
                  float2 direction) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    // Safely normalize direction: if zero-length, default to upward
    float dirLength = length(direction);
    float2 dirNorm = (dirLength > 0.0001) ? (direction / dirLength) : float2(0.0, 1.0);
    // - progress == 0 -> sample from offscreen (hidden)
    // - progress == 1 -> sample from uv (visible)
    float2 sampleUV = uv + (1.0 - progress) * dirNorm;
    // Determine visibility: if sampleUV is inside [0,1] range, show; else hide
    float inBounds = step(0.0, sampleUV.x) * step(sampleUV.x, 1.0) * step(0.0, sampleUV.y) * step(sampleUV.y, 1.0);
    
    float2 samplePos = clamp(sampleUV, float2(0.0), float2(1.0)) * size;
    half4 color = layer.sample(samplePos);
    return color * half(inBounds);
}
