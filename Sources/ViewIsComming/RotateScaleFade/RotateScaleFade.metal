#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: Mark Craig
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/rotate_scale_fade.glsl
// SwiftUI single-view adaptation: the "to" side of the original. The view
// spins and zooms in towards `center`, peaking at progress 0.5, while it fades
// in. Areas the rotated view does not cover stay transparent (the original
// fills them with a background colour).

[[ stitchable ]] half4 rotateScaleFade(float2 position,
                                       SwiftUI::Layer layer,
                                       float2 size,
                                       float progress,
                                       float2 center,
                                       float rotations,
                                       float scale) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    float2 difference = uv - center;
    float dist = length(difference);
    float2 dir = dist > 0.00001 ? difference / dist : float2(0.0);

    float angle = 2.0 * 3.14159265359 * rotations * progress;

    float c = cos(angle);
    float s = sin(angle);

    float currentScale = max(mix(scale, 1.0, 2.0 * abs(progress - 0.5)), 0.0001);

    float2 rotatedDir = float2(dir.x * c - dir.y * s, dir.x * s + dir.y * c);
    float2 rotatedUv = center + rotatedDir * dist / currentScale;

    if (rotatedUv.x < 0.0 || rotatedUv.x > 1.0 ||
        rotatedUv.y < 0.0 || rotatedUv.y > 1.0) {
        return half4(0.0);
    }

    return layer.sample(rotatedUv * size) * half(progress);
}
