#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// LuminanceMelt transition
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/luminance_melt.glsl
// Author: 0gust1
// License: MIT
// SwiftUI single-view adaptation: the view appears in noisy vertical streaks
// whose spread depends on the luminance of each pixel (dark pixels melt in
// first). The remaining area cross-fades in with progress³. `direction` picks
// the melt direction (>= 0.5 melts downwards) and `smoothness` softens the
// luminance threshold.

float luminanceMelt_rand(float2 co) {
    return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

// Simplex noise
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : MIT
//               2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License.
//               https://github.com/ashima/webgl-noise

float2 luminanceMelt_mod289(float2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 luminanceMelt_mod289(float3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 luminanceMelt_permute(float3 x) {
    return luminanceMelt_mod289(((x * 34.0) + 1.0) * x);
}

float luminanceMelt_snoise(float2 v) {
    const float4 C = float4(0.211324865405187,    // (3.0-sqrt(3.0))/6.0
                            0.366025403784439,    // 0.5*(sqrt(3.0)-1.0)
                            -0.577350269189626,   // -1.0 + 2.0 * C.x
                            0.024390243902439);   // 1.0 / 41.0
    // First corner
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Other corners
    float2 i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
    float4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;

    // Permutations
    i = luminanceMelt_mod289(i);
    float3 p = luminanceMelt_permute(luminanceMelt_permute(i.y + float3(0.0, i1.y, 1.0))
                                     + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m * m;
    m = m * m;

    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    float3 x = 2.0 * fract(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m.
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

    float3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

[[ stitchable ]] half4 luminanceMelt(float2 position,
                                     SwiftUI::Layer layer,
                                     float2 size,
                                     float progress,
                                     float direction,
                                     float threshold,
                                     float smoothness) {
    half4 color = layer.sample(position);
    if (progress >= 1.0) {
        return color;
    }

    // gl-transitions uses a bottom-left origin; flip y to keep its orientation.
    float2 uv = position / size;
    float2 p = float2(uv.x, 1.0 - uv.y);

    float2 center = float2(1.0, direction >= 0.5 ? 1.0 : 0.0);
    float dist = distance(center, p) - progress * exp(luminanceMelt_snoise(float2(p.x, 0.0)));
    float r = progress - luminanceMelt_rand(float2(p.x, 0.1));

    float luma = dot(float3(color.rgb), float3(0.299, 0.587, 0.114));
    float soft = max(smoothness, 0.0001);
    float dark = 1.0 - smoothstep(threshold - soft, threshold + soft, luma);

    float melted = step(dist, r) * dark;
    float m = mix(progress * progress * progress, 1.0, melted);

    return color * half(m);
}
