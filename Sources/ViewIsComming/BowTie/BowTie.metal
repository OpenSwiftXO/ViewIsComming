#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Helper function to check which side of a line a point is on
float check(float2 p1, float2 p2, float2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

// Check if point is inside a triangle
bool pointInTriangle(float2 pt, float2 p1, float2 p2, float2 p3) {
    bool b1 = check(pt, p1, p2) < 0.0;
    bool b2 = check(pt, p2, p3) < 0.0;
    bool b3 = check(pt, p3, p1) < 0.0;
    return (b1 == b2) && (b2 == b3);
}

// Calculate edge blur for smooth transitions
float blurEdge(float2 bot1, float2 bot2, float2 top, float2 testPt) {
    float2 lineDir = bot1 - top;
    float2 perpDir = float2(lineDir.y, -lineDir.x);
    float2 dirToPt1 = bot1 - testPt;
    float dist1 = abs(dot(normalize(perpDir), dirToPt1));
    lineDir = bot2 - top;
    perpDir = float2(lineDir.y, -lineDir.x);
    dirToPt1 = bot2 - testPt;
    float min_dist = min(abs(dot(normalize(perpDir), dirToPt1)), dist1);
    if (min_dist < 0.005) {
        return min_dist / 0.005;
    }
    return 1.0;
}

[[ stitchable ]]
half4 bowTieHorizontal(float2 position,
                       SwiftUI::Layer layer,
                       float2 size,
                       float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float mask = 0.0;
    // Left triangle check
    float2 leftVertex1 = float2(progress, 0.5);
    float2 leftVertex2 = float2(0.0, 0.5 - progress);
    float2 leftVertex3 = float2(0.0, 0.5 + progress);
    bool inLeftTriangle = pointInTriangle(uv, leftVertex1, leftVertex2, leftVertex3);
    // Right triangle check
    float2 rightVertex1 = float2(1.0 - progress, 0.5);
    float2 rightVertex2 = float2(1.0, 0.5 - progress);
    float2 rightVertex3 = float2(1.0, 0.5 + progress);
    bool inRightTriangle = pointInTriangle(uv, rightVertex1, rightVertex2, rightVertex3);
    
    if (inLeftTriangle) {
        if (progress < 0.1) {
            mask = 0.0;
        } else if (uv.x < 0.5) {
            mask = blurEdge(leftVertex2, leftVertex3, leftVertex1, uv);
        } else {
            mask = progress > 0.0 ? 1.0 : 0.0;
        }
    } else if (inRightTriangle) {
        if (uv.x >= 0.5) {
            mask = blurEdge(rightVertex2, rightVertex3, rightVertex1, uv);
        } else {
            mask = 0.0;
        }
    }
    
    half4 color = layer.sample(position);
    return color * half(mask);
}

[[ stitchable ]]
half4 bowTieVertical(float2 position,
                     SwiftUI::Layer layer,
                     float2 size,
                     float progress) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    float2 uv = position / size;
    float mask = 0.0;
    // Top triangle check
    float2 topVertex1 = float2(0.5, progress);
    float2 topVertex2 = float2(0.5 - progress, 0.0);
    float2 topVertex3 = float2(0.5 + progress, 0.0);
    bool inTopTriangle = pointInTriangle(uv, topVertex1, topVertex2, topVertex3);
    // Bottom triangle check
    float2 bottomVertex1 = float2(0.5, 1.0 - progress);
    float2 bottomVertex2 = float2(0.5 - progress, 1.0);
    float2 bottomVertex3 = float2(0.5 + progress, 1.0);
    bool inBottomTriangle = pointInTriangle(uv, bottomVertex1, bottomVertex2, bottomVertex3);
    
    if (inTopTriangle) {
        if (progress < 0.1) {
            mask = 0.0;
        } else if (uv.y < 0.5) {
            mask = blurEdge(topVertex2, topVertex3, topVertex1, uv);
        } else {
            mask = progress > 0.0 ? 1.0 : 0.0;
        }
    } else if (inBottomTriangle) {
        if (uv.y >= 0.5) {
            mask = blurEdge(bottomVertex2, bottomVertex3, bottomVertex1, uv);
        } else {
            mask = 0.0;
        }
    }
    
    half4 color = layer.sample(position);
    return color * half(mask);
}
