#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Slide transition
// Single-view adaptation: the view slides in from the given direction without
// fading. progress 0 = fully off-screen in direction, 1 = in place.

[[ stitchable ]] half4 slide(float2 position,
                              SwiftUI::Layer layer,
                              float2 size,
                              float progress,
                              float2 direction) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float2 sampleUV = uv - direction * (1.0 - progress);

    if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
        sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        return half4(0.0);
    }

    return layer.sample(sampleUV * size);
}
