#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: TimDonselaar
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/GridFlip.glsl
// SwiftUI single-view adaptation: the "to" side of every tile. Tiles are
// hidden until they have flipped past edge-on, divider lines stay empty while
// the tiles flip and fade in during the closing pause.

float gridFlip_rand(float2 co) {
    return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

// Distance of `p` to the closest tile border.
float gridFlip_getDelta(float2 p, float2 grid) {
    float2 rectanglePos = floor(grid * p);
    float2 rectangleSize = 1.0 / grid;
    float top = rectangleSize.y * (rectanglePos.y + 1.0);
    float bottom = rectangleSize.y * rectanglePos.y;
    float left = rectangleSize.x * rectanglePos.x;
    float right = rectangleSize.x * (rectanglePos.x + 1.0);
    float minX = min(abs(p.x - left), abs(p.x - right));
    float minY = min(abs(p.y - top), abs(p.y - bottom));
    return min(minX, minY);
}

float gridFlip_getDividerSize(float2 grid, float dividerWidth) {
    float2 rectangleSize = 1.0 / grid;
    return min(rectangleSize.x, rectangleSize.y) * dividerWidth;
}

[[ stitchable ]] half4 gridFlip(float2 position,
                                SwiftUI::Layer layer,
                                float2 size,
                                float progress,
                                float2 gridSize,
                                float pause,
                                float dividerWidth,
                                float randomness) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 p = position / size;
    float2 grid = max(floor(gridSize), float2(1.0));
    float pauseTime = clamp(pause, 0.0001, 0.45);

    bool onDivider = gridFlip_getDelta(p, grid) < gridFlip_getDividerSize(grid, dividerWidth);

    if (progress < pauseTime) {
        // Opening pause: only the outgoing image is on screen.
        return half4(0.0);
    }

    if (progress < 1.0 - pauseTime) {
        if (onDivider) {
            return half4(0.0);
        }

        float currentProg = (progress - pauseTime) / (1.0 - pauseTime * 2.0);

        float2 rectanglePos = floor(grid * p);
        float r = gridFlip_rand(rectanglePos) - randomness;
        float cp = smoothstep(0.0, max(1.0 - r, 0.001), currentProg);

        float rectangleSize = 1.0 / grid.x;
        float delta = rectanglePos.x * rectangleSize;
        float offset = rectangleSize / 2.0 + delta;

        // Horizontal squeeze of the tile around its centre line.
        float squeeze = max(abs(cp - 0.5), 0.0001);
        float2 q = float2((p.x - offset) / squeeze * 0.5 + offset, p.y);

        float visible = step(abs(grid.x * (p.x - delta) - 0.5), abs(cp - 0.5));
        // The back half of the flip shows the incoming image.
        float incoming = step(0.5, cp);

        return layer.sample(clamp(q, 0.0, 1.0) * size) * half(visible * incoming);
    }

    // Closing pause: dividers fade in.
    float currentProg = (progress - 1.0 + pauseTime) / pauseTime;
    float alpha = onDivider ? currentProg : 1.0;
    return layer.sample(position) * half(alpha);
}
