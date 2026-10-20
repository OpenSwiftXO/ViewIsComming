#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

float crossHatch_rand(float2 co) {
    return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

[[ stitchable ]]
half4 crossHatch(float2 position,
                 SwiftUI::Layer layer,
                 float2 size,
                 float progress,
                 float2 center,
                 float threshold,
                 float fadeEdge) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    float dist = distance(center, uv) / threshold;
    float r = progress - min(crossHatch_rand(float2(uv.y, 0.0)), crossHatch_rand(float2(0.0, uv.x)));
    // Calculate mask
    float mask = mix(0.0, mix(step(dist, r), 1.0, smoothstep(1.0 - fadeEdge, 1.0, progress)), smoothstep(0.0, fadeEdge, progress));
    // Sample and apply mask
    half4 color = layer.sample(position);
    return color * half(mask);
}
