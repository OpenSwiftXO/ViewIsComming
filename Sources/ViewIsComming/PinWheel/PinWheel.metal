#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 pinWheel(float2 position,
               SwiftUI::Layer layer,
               float2 size,
               float progress,
               float blades) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates to [0, 1]
    float2 uv = position / size;
    // Calculate circular position with rotation
    float circPos = atan2(uv.y - 0.5, uv.x - 0.5) + progress * 2.0;
    // Calculate segment size based on number of blades
    float segment = 2.0 * 3.1415926 / blades;
    float modPos = fmod(circPos, segment);
    // Normalize modPos to always be positive
    if (modPos < 0.0) {
        modPos += segment;
    }
    // Calculate threshold for current progress
    float threshold = progress * segment;
    float signedValue = sign(threshold - modPos);
    // Sample the layer
    half4 color = layer.sample(position);
    // Calculate mask for pinwheel effect
    float mask = 1.0 - step(signedValue, 0.5);
    
    return color * half(mask);
}
