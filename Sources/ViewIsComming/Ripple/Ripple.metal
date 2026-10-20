#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Ripple transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/ripple.glsl
// Author: gre
// License: MIT
// SwiftUI single-view adaptation: the original ripples its outgoing image, so
// the view plays that "from" branch in reverse – it starts rippled and faded
// out and settles into place. SwiftUI plays the same effect forwards when the
// view is removed.

[[stitchable]] half4 ripple(float2 position,
                            SwiftUI::Layer layer,
                            float2 size,
                            float progress,
                            float amplitude,
                            float speed) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float t = 1.0 - progress;

    float2 dir = uv - 0.5;
    float dist = length(dir);
    float2 offset = dir * (sin(t * dist * amplitude - t * speed) + 0.5) / 30.0 * t;

    float2 samplePos = clamp(uv + offset, 0.0, 1.0) * size;
    half4 color = layer.sample(samplePos);

    return color * half(1.0 - smoothstep(0.2, 1.0, t));
}
