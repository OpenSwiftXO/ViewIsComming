#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// MultiplyBlend transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/multiply_blend.glsl
// Author: Fernando Kuteken
// License: MIT
// SwiftUI single-view adaptation: the original fades through the product of
// both images. With only one view the "blend" is the view multiplied with
// itself (raised to 1 + `intensity`), which fades in during the first half and
// relaxes back to the plain view during the second half.

[[ stitchable ]] half4 multiplyBlend(float2 position,
                                     SwiftUI::Layer layer,
                                     float2 size,
                                     float progress,
                                     float intensity) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    half4 view = layer.sample(position);
    if (view.a <= 0.0h) {
        return view;
    }

    // Work on straight (un-premultiplied) colour to multiply it correctly.
    float3 straight = float3(view.rgb) / float(view.a);
    float3 blended = pow(straight, float3(1.0 + max(intensity, 0.0)));

    float3 rgb;
    float alpha;
    if (progress < 0.5) {
        rgb = blended;
        alpha = 2.0 * progress;
    } else {
        rgb = mix(blended, straight, 2.0 * progress - 1.0);
        alpha = 1.0;
    }

    half a = view.a * half(alpha);
    return half4(half3(rgb) * a, a);
}
