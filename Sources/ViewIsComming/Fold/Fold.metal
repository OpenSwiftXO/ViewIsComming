#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Fold transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/fold.glsl
// Author: bobylito
// License: MIT
// SwiftUI single-view adaptation: the appearing view is compressed into the
// right-hand strip `progress` wide and expands to full width as progress→1.

[[ stitchable ]] half4 fold(float2 position,
                            SwiftUI::Layer layer,
                            float2 size,
                            float progress,
                            float folds,
                            float intensity) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float threshold = 1.0 - progress;
    if (uv.x < threshold) {
        return half4(0.0);
    }

    float p = max(progress, 0.0001);
    float sx = (uv.x - threshold) / p;
    float2 sampleUV = float2(sx, uv.y);

    half4 color = layer.sample(sampleUV * size);

    // Optional folded-paper shading: darken by sine of local fold position.
    float foldCount = max(folds, 1.0);
    float foldPos = fract(sx * foldCount);
    float shade = 1.0 - intensity * (1.0 - progress) * sin(foldPos * 3.14159265359);
    return color * half(shade);
}
