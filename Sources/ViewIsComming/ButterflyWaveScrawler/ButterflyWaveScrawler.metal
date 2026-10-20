#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
#include "../Constants.metal"
using namespace metal;

// Butterfly polar function for displacement calculation
float butterflyWaveCompute(float2 p, float progress, float2 center, float amplitude, float waves) {
    float2 o = p * sin(progress * amplitude) - center;
    // horizontal vector
    float2 h = float2(1.0, 0.0);
    // butterfly polar – acos() needs its argument clamped to stay finite
    float theta = acos(clamp(dot(o, h), -1.0, 1.0)) * waves;
    // sin^5 written out: pow() with a negative base is NaN in fast-math Metal
    float s = sin((2.0 * theta - PI) / 24.0);
    float s2 = s * s;
    return (exp(cos(theta)) - 2.0 * cos(4.0 * theta) + s2 * s2 * s) / 10.0;
}

[[ stitchable ]]
half4 butterflyWaveScrawler(float2 position,
                            SwiftUI::Layer layer,
                            float2 size,
                            float progress,
                            float amplitude,
                            float waves,
                            float colorSeparation) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Calculate displacement using butterfly wave function
    float disp = butterflyWaveCompute(uv, progress, float2(0.5, 0.5), amplitude, waves);
    // Apply displacement to sampling position
    // As view appears (progress 0->1), we apply displacement scaled by (1-progress)
    float inv = 1.0 - progress;
    float2 displacement = float2(disp, disp);
    // Sample with chromatic aberration effect
    // Red channel: sample with negative color separation
    float2 uvR = uv + inv * displacement * (1.0 - colorSeparation);
    // Green channel: sample at base displacement
    float2 uvG = uv + inv * displacement;
    // Blue channel: sample with positive color separation
    float2 uvB = uv + inv * displacement * (1.0 + colorSeparation);
    // Convert back to pixel coordinates for sampling
    float2 posR = uvR * size;
    float2 posG = uvG * size;
    float2 posB = uvB * size;
    // Sample each color channel separately
    half r = layer.sample(posR).r;
    half g = layer.sample(posG).g;
    half b = layer.sample(posB).b;
    half a = layer.sample(posG).a;
    // Combine channels
    half4 color = half4(r, g, b, a);
    // Apply visibility mask (fade in as progress increases)
    float mask = progress;
    
    return color * half(mask);
}
