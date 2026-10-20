#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// DreamyZoom transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/DreamyZoom.glsl
// Author: zeh
// License: MIT
// SwiftUI single-view adaptation: sample the "to" branch with the same
// rotate+zoom, and fade in via smoothstep(0.2, 0.8, progress).

[[ stitchable ]] half4 dreamyZoom(float2 position,
                                  SwiftUI::Layer layer,
                                  float2 size,
                                  float progress,
                                  float rotation,
                                  float scale) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float2 p = uv - 0.5;

    // Triangle wave: 0 → 1 → 0 peaking at progress = 0.5.
    float phase = progress < 0.5 ? 2.0 * progress : 2.0 * (1.0 - progress);
    float angle = phase * rotation * 3.14159265359 / 180.0;
    float newScale = max(1.0 + phase * (scale - 1.0), 0.0001);

    float s = sin(angle);
    float c = cos(angle);
    float2 rotated = float2(p.x * c - p.y * s, p.x * s + p.y * c) / newScale;
    float2 sampleUV = rotated + 0.5;

    if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
        sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        return half4(0.0);
    }

    half4 color = layer.sample(sampleUV * size);
    float mask = smoothstep(0.2, 0.8, progress);
    return color * half(mask);
}
