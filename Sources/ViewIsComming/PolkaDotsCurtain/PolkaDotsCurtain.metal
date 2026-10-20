#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 polkaDotsCurtain(float2 position,
                       SwiftUI::Layer layer,
                       float2 size,
                       float progress,
                       float dots,
                       float2 center) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    // Calculate distance from each dot center
    float2 fractUV = fract(uv * dots);
    float distFromDotCenter = distance(fractUV, float2(0.5, 0.5));
    // Distance from the specified center point
    float distFromCenter = distance(uv, center);
    // Check if this pixel should be visible based on dot pattern
    // Dots reveal outward from center as progress increases
    bool shouldReveal = distFromDotCenter < (progress / distFromCenter);
    // Show view where dots should be revealed
    float mask = shouldReveal ? 1.0 : 0.0;
    half4 color = layer.sample(position);
    return color * half(mask);
}
