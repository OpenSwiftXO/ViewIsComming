#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Author: Fernando Kuteken
// License: MIT
// Ported from: https://github.com/gl-transitions/gl-transitions/blob/master/transitions/hexagonalize.glsl

struct HexagonalizeHexagon {
    float q;
    float r;
    float s;
};

HexagonalizeHexagon hexagonalize_createHexagon(float q, float r) {
    HexagonalizeHexagon hex;
    hex.q = q;
    hex.r = r;
    hex.s = -q - r;
    return hex;
}

HexagonalizeHexagon hexagonalize_roundHexagon(HexagonalizeHexagon hex) {
    float q = floor(hex.q + 0.5);
    float r = floor(hex.r + 0.5);
    float s = floor(hex.s + 0.5);
    
    float deltaQ = abs(q - hex.q);
    float deltaR = abs(r - hex.r);
    float deltaS = abs(s - hex.s);
    
    if (deltaQ > deltaR && deltaQ > deltaS)
        q = -r - s;
    else if (deltaR > deltaS)
        r = -q - s;
    else
        s = -q - r;
    
    return hexagonalize_createHexagon(q, r);
}

HexagonalizeHexagon hexagonalize_hexagonFromPoint(float2 point, float size, float ratio) {
    point.y /= ratio;
    point = (point - 0.5) / size;
    
    float q = (sqrt(3.0) / 3.0) * point.x + (-1.0 / 3.0) * point.y;
    float r = 0.0 * point.x + 2.0 / 3.0 * point.y;
    
    HexagonalizeHexagon hex = hexagonalize_createHexagon(q, r);
    return hexagonalize_roundHexagon(hex);
}

float2 hexagonalize_pointFromHexagon(HexagonalizeHexagon hex, float size, float ratio) {
    float x = (sqrt(3.0) * hex.q + (sqrt(3.0) / 2.0) * hex.r) * size + 0.5;
    float y = (0.0 * hex.q + (3.0 / 2.0) * hex.r) * size + 0.5;
    
    return float2(x, y * ratio);
}

[[ stitchable ]] half4 hexagonalize(float2 position,
                                    SwiftUI::Layer layer,
                                    float2 size,
                                    float progress,
                                    float steps,
                                    float horizontalHexagons) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    float ratio = size.y / size.x;
    
    float dist = 2.0 * min(progress, 1.0 - progress);
    dist = steps > 0 ? ceil(dist * steps) / steps : dist;
    
    float hexSize = (sqrt(3.0) / 3.0) * dist / horizontalHexagons;
    
    float2 point = dist > 0.0 ? hexagonalize_pointFromHexagon(hexagonalize_hexagonFromPoint(uv, hexSize, ratio), hexSize, ratio) : uv;
    
    // Sample at the hexagon center point. Apply progress mask so the view
    // fades in/out with the transition (progress 0 = hidden, 1 = visible).
    half4 color = layer.sample(point * size);
    return color * half(progress);
}
