#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 crazyParametric(float2 position,
                      SwiftUI::Layer layer,
                      float2 size,
                      float progress,
                      float outerRadius,
                      float innerRadius,
                      float waveIntensity,
                      float waveSmooth) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Calculate direction from center
    float2 dir = uv - float2(0.5);
    float dist = length(dir);
    // Parametric fun equations (hypotrochoid)
    float x = (outerRadius - innerRadius) * cos(progress) + innerRadius * cos(progress * ((outerRadius / innerRadius) - 1.0));
    float y = (outerRadius - innerRadius) * sin(progress) - innerRadius * sin(progress * ((outerRadius / innerRadius) - 1.0));
    // Calculate offset based on parametric function
    float2 offset = dir * float2(sin(progress * dist * waveIntensity * x), sin(progress * dist * waveIntensity * y)) / waveSmooth;
    // Sample position: start with offset, transition to normal position
    float2 sampleUV = uv + offset * (1.0 - progress);
    float2 samplePos = sampleUV * size;
    // Check bounds - only apply during transition
    float mask = 1.0;
    if (progress < 0.95) {  // Only check bounds during transition
        if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
            sampleUV.y < 0.0 || sampleUV.y > 1.0) {
            mask = 0.0;
        }
    }
    // Apply smooth fade based on progress
    mask *= smoothstep(0.2, 1.0, progress);
    
    // Sample and apply mask
    half4 color = layer.sample(samplePos);
    return color * half(mask);
}
