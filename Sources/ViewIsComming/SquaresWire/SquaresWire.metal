#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

[[ stitchable ]]
half4 squaresWire(float2 position,
                  SwiftUI::Layer layer,
                  float2 size,
                  float progress,
                  float2 squares,
                  float2 direction,
                  float smoothness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float2 center = float2(0.5, 0.5);
    // Normalize direction vector
    float2 v = normalize(direction);
    v /= abs(v.x) + abs(v.y);
    // Calculate distance from center
    float d = v.x * center.x + v.y * center.y;
    float offset = smoothness;
    // Calculate progress ratio with smoothstep
    float pr = smoothstep(-offset, 0.0, v.x * uv.x + v.y * uv.y - (d - 0.5 + progress * (1.0 + offset)));
    // Calculate square pattern
    float2 squarep = fract(uv * squares);
    float2 squaremin = float2(pr / 2.0);
    float2 squaremax = float2(1.0 - pr / 2.0);
    // Calculate alpha mask for squares
    float a = (1.0 - step(progress, 0.0)) *
    step(squaremin.x, squarep.x) *
    step(squaremin.y, squarep.y) *
    step(squarep.x, squaremax.x) *
    step(squarep.y, squaremax.y);
    // Sample the layer
    half4 color = layer.sample(position);
    // Apply the square wire mask
    return color * half(a);
}
