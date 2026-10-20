#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// 3D flip transition (custom – no direct gl-transitions equivalent).
// Simulates a card rotation around the chosen axis: at progress 0 the view is
// edge-on (hidden), at progress 1 it faces the viewer (fully visible).

[[ stitchable ]] half4 flip(float2 position,
                            SwiftUI::Layer layer,
                            float2 size,
                            float progress,
                            float axis,
                            float perspective) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;

    // Rotation: 90° at progress 0, 0° at progress 1.
    float angle = (1.0 - progress) * 1.5707963267948966;
    float c = cos(angle);
    if (c < 0.001) {
        return half4(0.0);
    }

    float2 centered = uv - 0.5;
    float2 sampleUV;
    if (axis < 0.5) {
        // Rotate around vertical axis – stretch X back out.
        sampleUV = float2(centered.x / c, centered.y) + 0.5;
    } else {
        // Rotate around horizontal axis – stretch Y back out.
        sampleUV = float2(centered.x, centered.y / c) + 0.5;
    }

    // Clip pixels outside the unrotated card.
    if (sampleUV.x < 0.0 || sampleUV.x > 1.0 ||
        sampleUV.y < 0.0 || sampleUV.y > 1.0) {
        return half4(0.0);
    }

    half4 color = layer.sample(sampleUV * size);

    // Perspective shading: darken the card as it tilts away.
    float shade = mix(1.0, c, clamp(perspective, 0.0, 1.0));
    float alpha = smoothstep(0.0, 0.05, c);
    return color * half(shade) * half(alpha);
}
