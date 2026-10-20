#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Pixelize transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/pixelize.glsl
// Author: gre
// License: MIT
// SwiftUI single-view adaptation: the view pixelates while it fades in and
// sharpens again towards progress 1.

[[ stitchable ]] half4 pixelize(float2 position,
                                 SwiftUI::Layer layer,
                                 float2 size,
                                 float progress,
                                 float squaresMin,
                                 float steps) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    float d = min(progress, 1.0 - progress);
    float dist = steps > 0.0 ? ceil(d * steps) / steps : d;

    float2 squareSize = 2.0 * dist / float2(max(squaresMin, 1.0));
    float2 p = dist > 0.0 ? (floor(uv / squareSize) + 0.5) * squareSize : uv;

    return layer.sample(clamp(p, 0.0, 1.0) * size) * half(progress);
}
