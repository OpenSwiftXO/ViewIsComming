#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: Ben Lucas
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/StaticFade.glsl
// SwiftUI single-view adaptation: the view cuts in halfway through the
// transition, hidden behind a burst of static that peaks at progress 0.5.

float staticFade_rnd(float2 st) {
    return fract(sin(dot(st, float2(10.5302340293, 70.23492931))) * 12345.5453123);
}

float3 staticFade_staticNoise(float2 st, float offset, float luminosity) {
    float staticR = luminosity * staticFade_rnd(st * float2(offset * 2.0, offset * 3.0));
    float staticG = luminosity * staticFade_rnd(st * float2(offset * 3.0, offset * 5.0));
    float staticB = luminosity * staticFade_rnd(st * float2(offset * 5.0, offset * 7.0));
    return float3(staticR, staticG, staticB);
}

float staticFade_staticIntensity(float t) {
    float transitionProgress = abs(2.0 * (t - 0.5));
    float transformedThreshold = 1.2 * (1.0 - transitionProgress) - 0.1;
    return min(1.0, transformedThreshold);
}

[[ stitchable ]] half4 staticFade(float2 position,
                                  SwiftUI::Layer layer,
                                  float2 size,
                                  float progress,
                                  float nNoisePixels,
                                  float staticLuminosity) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    // The incoming view only exists after the cut.
    half4 view = layer.sample(position) * half(step(0.5, progress));

    float noisePixels = max(nNoisePixels, 1.0);
    float2 uvStatic = floor(uv * noisePixels) / noisePixels;

    float3 staticColor = staticFade_staticNoise(uvStatic, progress, staticLuminosity);
    float staticThresh = staticFade_staticIntensity(progress);
    half staticMix = half(step(staticFade_rnd(uvStatic), staticThresh));

    return mix(view, half4(half3(staticColor), 1.0h), staticMix);
}
