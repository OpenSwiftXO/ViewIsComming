#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// TVStatic transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/TVStatic.glsl
// Author: Brandon Anzaldi
// License: MIT
// SwiftUI single-view adaptation: before `offset` nothing is visible (the
// original "from" image would be there), during the middle the static noise
// fills the frame, after `1 - offset` the sampled view fades in.

float tvStaticNoise(float2 co, float progress) {
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt = dot(co.xy * progress, float2(a, b));
    float sn = fmod(dt, 3.14);
    return fract(sin(sn) * c);
}

[[ stitchable ]] half4 tvStatic(float2 position,
                                 SwiftUI::Layer layer,
                                 float2 size,
                                 float progress,
                                 float offset) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float safeOffset = max(offset, 0.0001);

    if (progress < safeOffset) {
        // Fade noise in over nothing. The layer isn't visible yet.
        float noise = tvStaticNoise(uv, max(progress, 0.0001));
        float t = progress / safeOffset;
        return half4(half3(noise), 1.0) * half(t);
    } else if (progress > 1.0 - safeOffset) {
        // Cross-fade noise out to the sampled view.
        float noise = tvStaticNoise(uv, 1.0 - progress);
        float t = (progress - (1.0 - safeOffset)) / safeOffset;
        half4 view = layer.sample(position);
        half4 staticColor = half4(half3(noise), 1.0);
        return mix(staticColor, view, half(t));
    } else {
        // Pure static.
        float noise = tvStaticNoise(uv, progress);
        return half4(half3(noise), 1.0);
    }
}
