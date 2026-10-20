#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Burn transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/burn.glsl
// Author: gre
// License: MIT
// SwiftUI single-view adaptation: the "to" branch of the original, i.e. the
// view brightened toward `color` by (1 - progress) and weighted by progress.

[[ stitchable ]]
half4 burn(float2 position,
           SwiftUI::Layer layer,
           float2 size,
           float progress,
           float3 color) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    half4 view = layer.sample(position);
    half p = half(progress);

    // Layer samples are premultiplied, so the burn colour is scaled by alpha.
    half3 lit = view.rgb + half3(color) * (1.0h - p) * view.a;
    half alpha = view.a * p;

    // Keep the premultiplied result valid (rgb <= alpha).
    return half4(min(lit * p, half3(alpha)), alpha);
}
