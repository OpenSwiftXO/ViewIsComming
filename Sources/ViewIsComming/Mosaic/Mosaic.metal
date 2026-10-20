#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Mosaic transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/Mosaic.glsl
// Author: Xaychru
// License: MIT
// SwiftUI single-view adaptation: always sample the "to" branch. The view
// travels through the tiled plane and rotates random tiles along the way.

#define MOSAIC_PI 3.14159265359

float mosaicRand(float2 v) {
    return fract(sin(dot(v.xy, float2(12.9898, 78.233))) * 43758.5453);
}

[[ stitchable ]] half4 mosaic(float2 position,
                               SwiftUI::Layer layer,
                               float2 size,
                               float progress,
                               float endx,
                               float endy) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float2 p = uv - 0.5;
    float2 rp = p;

    float rpr = progress * 2.0 - 1.0;
    float z = -(rpr * rpr * 2.0) + 3.0;
    rp *= abs(z);

    float cosI = -cos(progress * MOSAIC_PI) / 2.0 + 0.5;
    float pow2 = cosI * cosI;
    rp += mix(float2(0.5), float2(endx + 0.5, endy + 0.5), pow2);

    float2 mrp = fract(rp);
    float2 crp = rp;
    int tx = int(floor(crp.x));
    int ty = int(floor(crp.y));
    bool onEnd = (tx == int(endx) && ty == int(endy));

    if (!onEnd) {
        float ang = floor(mosaicRand(floor(crp)) * 4.0) * 0.5 * MOSAIC_PI;
        float s = sin(ang);
        float c = cos(ang);
        float2 r = mrp - 0.5;
        mrp = float2(c * r.x - s * r.y, s * r.x + c * r.y) + 0.5;
    }

    half4 color = layer.sample(mrp * size);
    return color * half(progress);
}
