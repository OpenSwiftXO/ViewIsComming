#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// LinearBlur transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/LinearBlur.glsl
// Author: gre
// License: MIT

[[ stitchable ]] half4 linearBlur(float2 position,
                                   SwiftUI::Layer layer,
                                   float2 size,
                                   float progress,
                                   float intensity) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    // disp peaks at progress = 0.5 → 0.5 * intensity, zero at endpoints.
    float disp = intensity * (0.5 - abs(0.5 - progress));

    const int passes = 6;
    half4 sum = half4(0.0);
    for (int xi = 0; xi < passes; xi++) {
        float x = float(xi) / float(passes) - 0.5;
        for (int yi = 0; yi < passes; yi++) {
            float y = float(yi) / float(passes) - 0.5;
            float2 v = float2(x, y);
            float2 sampleUV = clamp(uv + disp * v, float2(0.0), float2(1.0));
            sum += layer.sample(sampleUV * size);
        }
    }
    half4 color = sum / half(passes * passes);
    return color * half(progress);
}
