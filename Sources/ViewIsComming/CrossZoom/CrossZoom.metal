#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// CrossZoom transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/CrossZoom.glsl
// Author: rectalogic
// License: MIT
// SwiftUI single-view adaptation: the "to" side of the original. The view is
// seen through a zoom blur that builds up to `strength` at progress 0.5 and
// relaxes again while the view dissolves in.

// Samples along each pixel's zoom ray; the original uses 40.
#define CROSS_ZOOM_SAMPLES 32

float crossZoom_rand(float2 co) {
    return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

float crossZoom_exponentialEaseInOut(float t) {
    if (t <= 0.0) {
        return 0.0;
    }
    if (t >= 1.0) {
        return 1.0;
    }
    t *= 2.0;
    if (t < 1.0) {
        return 0.5 * exp2(10.0 * (t - 1.0));
    }
    return 0.5 * (2.0 - exp2(-10.0 * (t - 1.0)));
}

[[ stitchable ]]
half4 crossZoom(float2 position,
                SwiftUI::Layer layer,
                float2 size,
                float progress,
                float strength) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float dissolve = crossZoom_exponentialEaseInOut(progress);
    if (dissolve <= 0.0) {
        return half4(0.0);
    }

    // Mirrored sinusoidal loop: 0 -> strength -> 0.
    float blur = 0.5 * strength * (1.0 - cos(4.0 * M_PI_F * 0.5 * progress));
    if (blur < 0.0001) {
        return layer.sample(position) * half(dissolve);
    }

    float2 texCoord = position / size;
    // The zoom centre travels across the middle half of the view.
    float2 center = float2(0.25 + 0.5 * progress, 0.5);
    float2 toCenter = center - texCoord;

    // Randomised start offset hides the fixed number of samples.
    float offset = crossZoom_rand(texCoord);

    half4 color = half4(0.0);
    float total = 0.0;
    for (int t = 0; t <= CROSS_ZOOM_SAMPLES; t++) {
        float percent = (float(t) + offset) / float(CROSS_ZOOM_SAMPLES);
        float weight = 4.0 * (percent - percent * percent);
        color += layer.sample((texCoord + toCenter * percent * blur) * size) * half(weight);
        total += weight;
    }

    return color / half(total) * half(dissolve);
}
