#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: Fernando Kuteken
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/polar_function.glsl
// SwiftUI single-view adaptation: the view is revealed inside the growing
// flower shape.

#define PI 3.14159265359

[[ stitchable ]] half4 polarFunction(float2 position,
                                     SwiftUI::Layer layer,
                                     float2 size,
                                     float progress,
                                     float segments) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    float angle = atan2(uv.y - 0.5, uv.x - 0.5) - 0.5 * PI;

    float radius = (cos(segments * angle) + 4.0) / 4.0;
    float difference = length(uv - float2(0.5, 0.5));

    // Inside the flower the incoming ("to") image shows.
    float mask = step(difference, radius * progress);

    return layer.sample(position) * half(mask);
}
