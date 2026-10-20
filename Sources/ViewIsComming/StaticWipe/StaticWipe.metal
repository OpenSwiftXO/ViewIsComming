#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: Ben Lucas
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/static_wipe.glsl
// SwiftUI single-view adaptation: the view is wiped in with a band of TV static
// along the wipe edge. `staticFade` softens the wipe edge (0 = hard edge as in
// the original).

#define PI 3.14159265359

float staticWipe_rnd(float2 st) {
    return fract(sin(dot(st, float2(10.0, 70.0))) * 12345.5453123);
}

[[ stitchable ]] half4 staticWipe(float2 position,
                                  SwiftUI::Layer layer,
                                  float2 size,
                                  float progress,
                                  float upToDown,
                                  float maximumStatic,
                                  float staticFade) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    float span = maximumStatic * pow(max(sin(PI * progress), 0.0), 0.5);

    // Distance travelled by the wipe: 0 at the edge it starts from. SwiftUI's
    // y axis points down, so "up to down" starts at y = 0.
    float transitionEdge = upToDown > 0.5 ? uv.y : 1.0 - uv.y;

    // Stretch the wipe by the edge softness so it is complete at progress 1.
    float soft = max(staticFade, 0.0);
    float front = progress * (1.0 + soft);
    float mixRatio = soft > 0.0001
        ? 1.0 - smoothstep(front - soft, front, transitionEdge)
        : 1.0 - step(progress, transitionEdge);

    half4 view = layer.sample(position) * half(mixRatio);

    float noiseEnvelope = smoothstep(progress - span, progress, transitionEdge)
        * (1.0 - smoothstep(progress, progress + span, transitionEdge));
    half4 noise = half4(half3(staticWipe_rnd(uv * (1.0 + progress))), 1.0h);

    return mix(view, noise, half(noiseEnvelope));
}
