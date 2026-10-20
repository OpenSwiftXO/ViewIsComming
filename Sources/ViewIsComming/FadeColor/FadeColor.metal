#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// FadeColor transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/fadecolor.glsl
// Author: gre
// License: MIT
// SwiftUI single-view adaptation: a solid color rectangle fades in over the
// view's area between progress 0 and `colorPhase`, then the view itself fades
// in between `colorPhase` and 1.

[[stitchable]] half4 fadeColor(float2 position,
                                 SwiftUI::Layer layer,
                                 float2 size,
                                 float progress,
                                 float3 color,
                                 float colorPhase) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    half4 view = layer.sample(position);

    float alpha1 = smoothstep(0.0, colorPhase, progress);
    float alpha2 = smoothstep(colorPhase, 1.0, progress);

    half3 rgb = mix(half3(color), view.rgb, half(alpha2));
    return half4(rgb, half(alpha1));
}
