#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: gre
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/fadegrayscale.glsl
// SwiftUI single-view adaptation: the "to" branch of the original – the view
// starts out grayscale and regains its colour as progress approaches 1.

float3 fadeGrayscale_grayscale(float3 color) {
    return float3(0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b);
}

[[ stitchable ]] half4 fadeGrayscale(float2 position,
                                     SwiftUI::Layer layer,
                                     float2 size,
                                     float progress,
                                     float intensity) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    half4 view = layer.sample(position);
    half4 gray = half4(half3(fadeGrayscale_grayscale(float3(view.rgb))), view.a);

    // smoothstep() needs edge0 < edge1.
    float edge = clamp(intensity, 0.0, 0.999);
    half color = half(smoothstep(edge, 1.0, progress));

    return mix(gray, view, color) * half(progress);
}
