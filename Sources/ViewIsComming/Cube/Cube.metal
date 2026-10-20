#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

bool inBounds(float2 p) {
    return p.x >= 0.0 && p.x <= 1.0 && p.y >= 0.0 && p.y <= 1.0;
}

float2 xskew(float2 p, float persp, float center) {
    float x = mix(p.x, 1.0 - p.x, center);
    float dist = abs(center - 0.5);
    // Apply perspective distortion to y coordinate
    float y = (p.y - 0.5 * (1.0 - persp) * x) / (1.0 + (persp - 1.0) * x);
    // Calculate scale and offset based on center position
    float scaleX = 0.5 / dist * (center < 0.5 ? 1.0 : -1.0);
    float offsetX = center < 0.5 ? 0.0 : 1.0;
    // Apply transformation
    float2 result = float2(x, y) - float2(0.5 - dist, 0.0);
    result = result * float2(scaleX, 1.0) + float2(offsetX, 0.0);
    return result;
}

[[ stitchable ]]
half4 cube(float2 position,
           SwiftUI::Layer layer,
           float2 size,
           float progress,
           float persp,
           float unzoom,
           float rotateRight) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Mirror UV for left rotation
    bool isRotateRight = rotateRight > 0.5;
    float2 workingUV = isRotateRight ? uv : float2(1.0 - uv.x, uv.y);
    // Apply unzoom effect
    float uz = unzoom * 2.0 * (0.5 - abs(0.5 - progress));
    float2 p = -uz * 0.5 + (1.0 + uz) * workingUV;
    // Calculate "from" face position (left side, disappearing)
    float2 fromP = xskew((p - float2(progress, 0.0)) / float2(1.0 - progress, 1.0), 1.0 - mix(progress, 0.0, persp), 0.0);
    // Calculate "to" face position (right side, appearing)
    float2 toP = xskew(p / float2(progress, 1.0), mix(pow(progress, 2.0), 1.0, persp), 1.0);
    
    float mask = 0.0;
    float2 sampleUV = uv;
    // Check which face is visible
    if (inBounds(fromP)) {
        // "From" face is visible (disappearing) - hide it as we're appearing
        mask = 0.0;
    } else if (inBounds(toP)) {
        // "To" face is visible (appearing) - this is our view
        // Un-mirror for left rotation
        float2 finalUV = isRotateRight ? toP : float2(1.0 - toP.x, toP.y);
        sampleUV = finalUV;
        mask = 1.0;
    }
    
    // Sample the layer
    half4 color = layer.sample(sampleUV * size);
    return color * half(mask);
}
