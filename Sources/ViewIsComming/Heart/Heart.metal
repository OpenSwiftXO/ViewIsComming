#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Heart transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/heart.glsl
// Author: gre
// License: MIT
// SwiftUI single-view adaptation: the view is revealed inside a heart that
// grows from the centre.

float heart_inHeart(float2 p, float2 center, float size) {
    if (size == 0.0) {
        return 0.0;
    }
    float2 o = (p - center) / (1.6 * size);
    float a = o.x * o.x + o.y * o.y - 0.3;
    return step(a * a * a, o.x * o.x * o.y * o.y * o.y);
}

[[ stitchable ]] half4 heart(float2 position,
                             SwiftUI::Layer layer,
                             float2 size,
                             float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // gl-transitions uses a bottom-left origin; flip y so the heart points down.
    float2 uv = position / size;
    uv.y = 1.0 - uv.y;

    float inside = heart_inHeart(uv, float2(0.5, 0.4), progress);
    return layer.sample(position) * half(inside);
}
