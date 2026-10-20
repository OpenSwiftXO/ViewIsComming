#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
#include "../Constants.metal"
using namespace metal;

float ubQuadraticInOut(float t) {
    float p = 2.0 * t * t;
    return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
}

// Calculate max distance from center to any corner of the view
float ubGetMaxRadius(float2 center) {
    // Distance to all 4 corners
    float d1 = distance(center, float2(0.0, 0.0));
    float d2 = distance(center, float2(1.0, 0.0));
    float d3 = distance(center, float2(0.0, 1.0));
    float d4 = distance(center, float2(1.0, 1.0));
    return max(max(d1, d2), max(d3, d4));
}

float ubGetWave(float2 p, float2 center, float progress, float maxRadius) {
    float2 _p = p - center;
    float rads = atan2(_p.y, _p.x);
    float degs = (rads * 180.0 / PI) + 180.0;
    float ratio = (PI * 30.0) / 360.0;
    degs = degs * ratio;
    float x = progress;
    float magnitude = mix(0.02, 0.09, smoothstep(0.0, 1.0, x));
    float offset = mix(40.0, 30.0, smoothstep(0.0, 1.0, x));
    float ease_degs = ubQuadraticInOut(sin(degs));
    float deg_wave_pos = (ease_degs * magnitude) * sin(x * offset);
    // Add generous buffer to ensure full coverage
    // Account for wave dips and edge effects
    float buffer = 1.25;  // 25% extra to fully cover all wave variations
    float totalRadius = maxRadius * buffer;
    // Scale wave radius to cover full view based on center position
    return (x + deg_wave_pos) * totalRadius;
}

float ubGetGradient(float r, float dist, float smoothness) {
    float d = r - dist;
    return mix(smoothstep(-smoothness, 0.0, r - dist * (1.0 + smoothness)), -1.0 - step(0.005, d), step(-0.005, d) * step(d, 0.01));
}

[[ stitchable ]]
half4 undulatingBurnOut(float2 position,
                        SwiftUI::Layer layer,
                        float2 size,
                        float progress,
                        float smoothness,
                        float2 center) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    if (progress <= 0.0) {
        return half4(0.0h);
    }

    float2 uv = position / size;
    float dist = distance(center, uv);
    // Calculate max radius based on center position
    float maxRadius = ubGetMaxRadius(center);
    // Scale smoothness based on maxRadius for consistent edge width
    float scaledSmoothness = smoothness * maxRadius;
    float waveR = ubGetWave(uv, center, progress, maxRadius);
    float m = ubGetGradient(waveR, dist, scaledSmoothness);
    half4 viewColor = layer.sample(position);
    // m > 0: INSIDE wave → show view
    // -2 < m <= 0: OUTSIDE wave → HIDE (transparent)
    // m <= -2: WAVE EDGE → show view with tint effect
    if (m > 0.0) {
        return viewColor;
    } else if (m > -2.0) {
        return half4(0.0h);
    } else {
        half4 tintedView = viewColor;
        tintedView.rgb *= 1.15h;
        return tintedView;
    }
}
