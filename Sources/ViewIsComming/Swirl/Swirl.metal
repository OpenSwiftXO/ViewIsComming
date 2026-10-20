#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 swirl(float2 position,
            SwiftUI::Layer layer,
            float2 size,
            float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float radius = 1.0;
    float2 uv = position / size;
    // Center the UV coordinates
    float2 centeredUV = uv - float2(0.5, 0.5);
    float dist = length(centeredUV);
    // Apply swirl effect within radius
    if (dist < radius) {
        float percent = (radius - dist) / radius;
        // Swirl intensity: 0 at progress=0, max at progress=0.5, 0 at progress=1
        // This creates the swirl-in and swirl-out effect
        float a = (progress <= 0.5) ? mix(0.0, 1.0, progress / 0.5) : mix(1.0, 0.0, (progress - 0.5) / 0.5);
        float theta = percent * percent * a * 8.0 * 3.14159;
        float s = sin(theta);
        float c = cos(theta);
        centeredUV = float2(dot(centeredUV, float2(c, -s)), dot(centeredUV, float2(s, c)));
    }
    // Restore UV coordinates
    centeredUV += float2(0.5, 0.5);
    // Calculate sample position
    float2 samplePos = centeredUV * size;
    // Sample the layer
    half4 color = layer.sample(samplePos);
    // Mask: progress=0 -> hidden, progress=1 -> visible
    float mask = progress;
    return color * half(mask);
}
