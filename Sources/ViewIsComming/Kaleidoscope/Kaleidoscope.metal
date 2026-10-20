#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
#include "../Constants.metal"
using namespace metal;

// Kaleidoscope transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/kaleidoscope.glsl
// Author: nwoeanhinnogaehr
// License: MIT
// SwiftUI single-view adaptation: the "to" side of the original. The view is
// crossfaded with its kaleidoscoped self, strongest at progress 0.5, and fades
// in with progress.

[[ stitchable ]] half4 kaleidoscope(float2 position,
                                    SwiftUI::Layer layer,
                                    float2 size,
                                    float progress,
                                    float speed,
                                    float angle,
                                    float power) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 p = position / size - 0.5;
    float t = pow(progress, power) * speed;

    for (int i = 0; i < 7; i++) {
        p = float2(sin(t) * p.x + cos(t) * p.y, sin(t) * p.y - cos(t) * p.x);
        t += angle;
        p = abs(glslMod(p, 2.0) - 1.0);
    }

    float warp = 1.0 - 2.0 * abs(progress - 0.5);
    half4 plain = layer.sample(position);
    half4 folded = layer.sample(p * size);

    return mix(plain, folded, half(warp)) * half(progress);
}
