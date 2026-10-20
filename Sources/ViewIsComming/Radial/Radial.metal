#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Radial transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/Radial.glsl
// Author: Xaychru
// License: MIT
// SwiftUI single-view adaptation: the view is revealed by a clock-like sweep.
// The sweep range is widened by `smoothness` so nothing of the view is left
// at progress 0 and all of it is visible at progress 1.

[[stitchable]] half4 radial(float2 position,
                            SwiftUI::Layer layer,
                            float2 size,
                            float progress,
                            float smoothness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    const float PI = 3.141592653589;

    float2 uv = position / size;
    float2 rp = uv * 2.0 - 1.0;
    float angle = atan2(rp.y, rp.x);

    // atan2() spans [-PI, PI]; the soft edge adds `smoothness` on the hidden side.
    float soft = max(smoothness, 0.0001);
    float threshold = mix(-PI - soft, PI, progress);
    float hidden = smoothstep(0.0, soft, angle - threshold);

    return layer.sample(position) * half(1.0 - hidden);
}
