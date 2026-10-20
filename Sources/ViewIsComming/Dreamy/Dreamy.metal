#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Dreamy transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/Dreamy.glsl
// Author: mikolalysenko
// License: MIT
// SwiftUI single-view adaptation: sample the "to" branch of the original
// transition (the view shakes vertically with a sine offset while fading in).

[[ stitchable ]] half4 dreamy(float2 position,
                               SwiftUI::Layer layer,
                               float2 size,
                               float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float inv = 1.0 - progress;
    float shifty = 0.03 * inv * cos(10.0 * (inv + uv.x));
    float2 sampleUV = uv + float2(0.0, shifty);

    if (sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        return half4(0.0);
    }

    half4 color = layer.sample(sampleUV * size);
    return color * half(progress);
}
