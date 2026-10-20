#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// SimpleBookCurl transition
// A cylindrical page-curl sweeping right-to-left that reveals the view
// beneath. SwiftUI single-view adaptation: the curl hides the "from" page
// (outside the revealed region nothing is drawn). progress 0 = fully covered,
// 1 = fully revealed.

[[ stitchable ]] half4 simpleBookCurl(float2 position,
                                      SwiftUI::Layer layer,
                                      float2 size,
                                      float progress,
                                      float curlAmount,
                                      float radius) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float curlEdge = 1.0 - progress;
    float r = max(radius, 0.0001);

    // Flat revealed region to the right of the curl edge.
    if (uv.x >= curlEdge) {
        half4 color = layer.sample(position);
        // Drop a subtle shadow near the edge cast by the overhanging curl.
        // Scale shadow strength by (1-progress) so it vanishes at p=1.
        float d = uv.x - curlEdge;
        float shadowStrength = clamp(1.0 - d / r, 0.0, 1.0) * curlAmount * 0.35 * (1.0 - progress);
        return color * half(1.0 - shadowStrength);
    }

    // Curled region – the rolling page wraps a visible sliver of the view.
    float d = curlEdge - uv.x;
    if (d < r) {
        float t = d / r;
        float arc = t * 1.5707963267948966; // 0 → π/2
        float compressedX = curlEdge + sin(arc) * r;
        if (compressedX <= 1.0) {
            half4 color = layer.sample(float2(compressedX, uv.y) * size);
            // Cylindrical lambert-ish shading on the back of the curl.
            float shade = 0.4 + 0.6 * cos(arc);
            return color * half(shade);
        }
    }

    return half4(0.0);
}
