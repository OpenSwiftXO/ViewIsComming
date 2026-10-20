#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// WaterDrop transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/WaterDrop.glsl
// Author: Paweł Płóciennik
// License: MIT
// SwiftUI single-view adaptation: the appearing view ripples outward from the
// centre while fading in. Amplitude/speed match the original uniforms.

[[ stitchable ]] half4 waterDrop(float2 position,
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
    float2 dir = uv - 0.5;
    float dist = length(dir);

    float2 sampleUV = uv;
    if (dist > progress) {
        // Outside the drop radius: apply the ripple offset to the view.
        float2 offset = dir * sin(dist * amplitude - progress * speed) * 0.02;
        sampleUV = uv + offset;
    }

    if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
        sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        return half4(0.0);
    }

    half4 color = layer.sample(sampleUV * size);
    return color * half(progress);
}
