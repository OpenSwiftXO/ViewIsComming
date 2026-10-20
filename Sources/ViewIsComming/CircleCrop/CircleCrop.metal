#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 circleCrop(float2 position,
                 SwiftUI::Layer layer,
                 float2 size,
                 float progress,
                 float smoothness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    // Center the UV coordinates
    float2 centered = uv - float2(0.5, 0.5);
    // Correct aspect ratio
    float aspectRatio = size.x / size.y;
    centered.x *= aspectRatio;
    float dist = length(centered);
    // Circle radius grows from 0 to cover full diagonal
    float maxRadius = sqrt(0.5 * aspectRatio * aspectRatio + 0.5);
    // Use smoothstep for smooth edge transition
    float edge = max(smoothness * 0.1, 0.0001);
    // Grow the radius over [-edge, maxRadius + edge] so the soft edge is fully
    // closed at progress 0 and fully open at progress 1.
    float radius = mix(-edge, maxRadius + edge, progress);
    float mask = smoothstep(radius - edge, radius + edge, dist);
    // Invert mask: inside circle = visible (1.0), outside = hidden (0.0)
    mask = 1.0 - mask;
    
    half4 color = layer.sample(position);
    return color * half(mask);
}
