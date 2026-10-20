#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Morph transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/Morph.glsl
// Author: paniq
// License: MIT
// SwiftUI single-view adaptation: the displacement that would have been
// computed from both images is derived from the appearing view alone.

[[ stitchable ]] half4 morph(float2 position,
                              SwiftUI::Layer layer,
                              float2 size,
                              float progress,
                              float strength) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    // Initial sample to compute a content-derived displacement.
    half4 cb = layer.sample(position);
    float2 ob = ((float2(cb.r, cb.g) + float(cb.b)) * 0.5) * 2.0 - 1.0;
    float2 oc = ob * strength;

    float w1 = 1.0 - progress;
    float2 sampleUV = uv - oc * w1;

    if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
        sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        return half4(0.0);
    }

    half4 color = layer.sample(sampleUV * size);
    return color * half(progress);
}
