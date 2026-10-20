#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/SimpleZoom.glsl
// Author: 0gust1
// License: MIT
// SwiftUI single-view adaptation: the original zooms into its outgoing image
// before fading it out, so the view plays that "from" branch in reverse – it
// starts zoomed in and faded out and settles into place. SwiftUI plays the same
// effect forwards when the view is removed.

[[ stitchable ]] half4 simpleZoom(float2 position,
                                  SwiftUI::Layer layer,
                                  float2 size,
                                  float progress,
                                  float zoomQuickness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float t = 1.0 - progress;

    float nQuick = clamp(zoomQuickness, 0.2, 1.0);
    float amount = smoothstep(0.0, nQuick, t);

    float2 zoomedUV = 0.5 + (uv - 0.5) * (1.0 - amount);
    half4 color = layer.sample(zoomedUV * size);

    float fade = smoothstep(nQuick - 0.2, 1.0, t);
    return color * half(1.0 - fade);
}
