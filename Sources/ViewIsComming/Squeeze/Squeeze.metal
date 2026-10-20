#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Squeeze transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/squeeze.glsl
// Author: gre
// License: MIT
// SwiftUI single-view adaptation: the appearing view un-squeezes vertically
// from a thin horizontal line at progress 0 to full size at progress 1.

[[ stitchable ]] half4 squeeze(float2 position,
                                SwiftUI::Layer layer,
                                float2 size,
                                float progress,
                                float colorSeparation) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float p = max(progress, 0.0001);

    // Inverse of the gl-transitions "from" squeeze – the view is compressed
    // into a thin band at progress 0 and stretched to full height at 1.
    float y = 0.5 + (uv.y - 0.5) / p;
    if (y < 0.0 || y > 1.0) {
        return half4(0.0);
    }

    float inv = 1.0 - progress;
    float2 fp = float2(uv.x, y);
    half4 color = half4(0.0);
    color.r = layer.sample((fp - inv * float2(0.0, colorSeparation)) * size).r;
    color.g = layer.sample(fp * size).g;
    color.b = layer.sample((fp + inv * float2(0.0, colorSeparation)) * size).b;
    color.a = 1.0;
    // Ensure fully hidden at progress=0 (guards the 1-pixel center line).
    return color * half(saturate(progress / 0.01));
}
