#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Inspired by https://github.com/gl-transitions/gl-transitions rectangle (martiniti)
// SwiftUI single-view adaptation: reveal the view through an axis-aligned
// rectangle expanding from the center. progress 0 = hidden, 1 = fully visible.

[[ stitchable ]] half4 rectangle(float2 position,
                                 SwiftUI::Layer layer,
                                 float2 size,
                                 float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float2 d = abs(uv - 0.5);
    float chebyshev = max(d.x, d.y);

    // Rectangle half-extent grows linearly with progress.
    // Overshoot by `edge` so that at p=1 the soft border lies outside the view.
    float edge = 0.02;
    float halfExtent = (0.5 + edge) * progress;
    // Correct smoothstep order (edge0 < edge1). 1-smoothstep gives inside=1, outside=0.
    float mask = 1.0 - smoothstep(halfExtent - edge, halfExtent + edge, chebyshev);
    // Kill the soft-edge leak near p=0.
    mask *= saturate(progress * 50.0);

    half4 color = layer.sample(position);
    return color * half(mask);
}
