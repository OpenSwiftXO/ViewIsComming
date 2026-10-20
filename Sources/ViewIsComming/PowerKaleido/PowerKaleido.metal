#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
#include "../Constants.metal"
using namespace metal;

// PowerKaleido transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/powerKaleido.glsl
// Author: Boundless
// License: MIT
// SwiftUI single-view adaptation: the "to" side of the original – the view
// folds into an animated kaleidoscope and unfolds while fading in.

// Mirror axes every 120 degrees (the original's `rad` constant).
constant float powerKaleido_deg = 120.0 / 180.0 * 3.14159265358979;

float2 powerKaleido_refl(float2 p, float2 o, float2 n) {
    return 2.0 * o + 2.0 * n * dot(p - o, n) - p;
}

float2 powerKaleido_rot(float2 p, float2 o, float a) {
    float s = sin(a);
    float c = cos(a);
    return o + float2x2(c, -s, s, c) * (p - o);
}

[[ stitchable ]] half4 powerKaleido(float2 position,
                                    SwiftUI::Layer layer,
                                    float2 size,
                                    float progress,
                                    float scale,
                                    float z,
                                    float speed) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float ratio = size.x / size.y;
    float dist = scale / 10.0;

    float2 uv0 = position / size;
    float2 uv = uv0 - 0.5;
    uv.x *= ratio;
    uv *= z;
    uv = powerKaleido_rot(uv, float2(0.0), progress * speed);

    // 10 passes over the three mirror axes (0°, 120°, 240°).
    for (int iter = 0; iter < 10; iter++) {
        for (int k = 0; k < 3; k++) {
            float i = float(k) * powerKaleido_deg;
            float s = sin(i);
            float c = cos(i);
            float lhs = uv.y - dist * c;
            float rhs = tan(i) * (uv.x + dist * s);
            // The mirror line faces up when cos(i) > 0 and down otherwise.
            bool outside = c > 0.0 ? lhs > rhs : lhs < rhs;
            if (outside) {
                uv = powerKaleido_refl(float2(uv.x + s * dist * 2.0, uv.y - c * dist * 2.0),
                                       float2(0.0), float2(c, s));
            }
        }
    }

    uv += 0.5;
    uv = powerKaleido_rot(uv, float2(0.5), progress * -speed);
    uv -= 0.5;
    uv.x /= ratio;
    uv += 0.5;
    // Triangle-wave fold keeps the lookup inside the view.
    uv = 2.0 * abs(uv / 2.0 - floor(uv / 2.0 + 0.5));

    float2 uvMix = mix(uv, uv0, cos(progress * PI * 2.0) / 2.0 + 0.5);
    float alpha = cos((progress - 1.0) * PI) / 2.0 + 0.5;

    return layer.sample(uvMix * size) * half(alpha);
}
