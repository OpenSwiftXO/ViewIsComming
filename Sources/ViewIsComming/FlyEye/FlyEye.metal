#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: gre
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/flyeye.glsl
// SwiftUI single-view adaptation: sample the "to" branch of the original
// transition and ramp visibility with progress.

[[ stitchable ]] half4 flyEye(float2 position,
                              SwiftUI::Layer layer,
                              float2 size,
                              float progress,
                              float eyeSize,
                              float zoom,
                              float colorSeparation) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float inv = 1.0 - progress;
    float2 disp = eyeSize * float2(cos(zoom * uv.x), sin(zoom * uv.y));
    float2 sampleUV = uv + inv * disp;

    // Bounds check to hide out-of-frame pixels
    float mask = progress;
    if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
        sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        mask = 0.0;
    }

    half4 color = layer.sample(sampleUV * size);
    return color * half(mask);
}
