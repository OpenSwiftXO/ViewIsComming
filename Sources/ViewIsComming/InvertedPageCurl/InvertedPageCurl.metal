#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
#include "../Constants.metal"
using namespace metal;

constant float IPC_MIN_AMOUNT = -0.16;
constant float IPC_MAX_AMOUNT = 1.5;
constant float IPC_CYLINDER_RADIUS = 1.0 / PI / 2.0;
constant float IPC_SCALE = 512.0;
constant float IPC_SHARPNESS = 3.0;

float3 ipc_hitPoint(float hitAngle, float yc, float3 point, float3x3 rrotation) {
    float hitPointVal = hitAngle / (2.0 * PI);
    point.y = hitPointVal;
    return rrotation * point;
}

float4 ipc_antiAlias(float4 color1, float4 color2, float distanc) {
    distanc *= IPC_SCALE;
    if (distanc < 0.0) return color2;
    if (distanc > 2.0) return color1;
    float dd = pow(1.0 - distanc / 2.0, IPC_SHARPNESS);
    return ((color2 - color1) * dd) + color1;
}

float ipc_distanceToEdge(float3 point) {
    float dx = abs(point.x > 0.5 ? 1.0 - point.x : point.x);
    float dy = abs(point.y > 0.5 ? 1.0 - point.y : point.y);
    if (point.x < 0.0) dx = -point.x;
    if (point.x > 1.0) dx = point.x - 1.0;
    if (point.y < 0.0) dy = -point.y;
    if (point.y > 1.0) dy = point.y - 1.0;
    if ((point.x < 0.0 || point.x > 1.0) && (point.y < 0.0 || point.y > 1.0))
        return sqrt(dx * dx + dy * dy);
    return min(dx, dy);
}

float4 ipc_seeThrough(float yc,
                      float2 p,
                      float2 originalPos,
                      float2 size,
                      SwiftUI::Layer layer,
                      float cylinderAngle,
                      float3x3 rotation,
                      float3x3 rrotation,
                      float directionRightToLeft,
                      float edgeTop) {
    float hitAngle = PI - (acos(yc / IPC_CYLINDER_RADIUS) - cylinderAngle);
    float3 point = ipc_hitPoint(hitAngle, yc, rotation * float3(p, 1.0), rrotation);
    if (yc <= 0.0 && (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0)) {
        return float4(0.0, 0.0, 0.0, 0.0);
    }
    if (yc > 0.0) {
        return float4(layer.sample(originalPos));
    }
    float2 sampleUV = point.xy;
    // Flip back to original coordinates
    if (directionRightToLeft < 0.5) {
        sampleUV.x = 1.0 - sampleUV.x;
    }
    if (edgeTop < 0.5) {
        sampleUV.y = 1.0 - sampleUV.y;
    }
    float2 samplePos = sampleUV * size;
    float4 color = float4(layer.sample(samplePos));
    float4 tcolor = float4(0.0, 0.0, 0.0, 0.0);
    return ipc_antiAlias(color, tcolor, ipc_distanceToEdge(point));
}

float4 ipc_seeThroughWithShadow(float yc,
                                float2 p,
                                float3 point,
                                float2 originalPos,
                                float2 size,
                                SwiftUI::Layer layer,
                                float amount,
                                float cylinderAngle,
                                float3x3 rotation,
                                float3x3 rrotation,
                                float directionRightToLeft,
                                float edgeTop) {
    float shadow = ipc_distanceToEdge(point) * 30.0;
    shadow = (1.0 - shadow) / 3.0;
    if (shadow < 0.0) shadow = 0.0;
    else shadow *= amount;
    float4 shadowColor = ipc_seeThrough(yc, p, originalPos, size, layer, cylinderAngle, rotation, rrotation, directionRightToLeft, edgeTop);
    shadowColor.r -= shadow;
    shadowColor.g -= shadow;
    shadowColor.b -= shadow;
    return shadowColor;
}

float4 ipc_backside(float yc,
                    float3 point,
                    float2 size,
                    SwiftUI::Layer layer,
                    float directionRightToLeft,
                    float edgeTop) {
    // Calculate sample position from transformed point
    float2 sampleUV = point.xy;
    // Flip back to original coordinates
    if (directionRightToLeft < 0.5) {
        sampleUV.x = 1.0 - sampleUV.x;
    }
    if (edgeTop < 0.5) {
        sampleUV.y = 1.0 - sampleUV.y;
    }
    float2 samplePos = sampleUV * size;
    float4 color = float4(layer.sample(samplePos));
    float gray = (color.r + color.b + color.g) / 15.0;
    gray += (8.0 / 10.0) * (pow(1.0 - abs(yc / IPC_CYLINDER_RADIUS), 2.0 / 10.0) / 2.0 + (5.0 / 10.0));
    color.rgb = float3(gray);
    return color;
}

float4 ipc_behindSurface(float2 p,
                         float yc,
                         float3 point,
                         float2 originalPos,
                         float2 size,
                         SwiftUI::Layer layer,
                         float amount,
                         float cylinderAngle,
                         float3x3 rrotation) {
    float shado = (1.0 - ((-IPC_CYLINDER_RADIUS - yc) / amount * 7.0)) / 6.0;
    shado *= 1.0 - abs(point.x - 0.5);
    yc = (-IPC_CYLINDER_RADIUS - IPC_CYLINDER_RADIUS - yc);
    float hitAngle = (acos(yc / IPC_CYLINDER_RADIUS) + cylinderAngle) - PI;
    point = ipc_hitPoint(hitAngle, yc, point, rrotation);
    if (yc < 0.0 && point.x >= 0.0 && point.y >= 0.0 && point.x <= 1.0 && point.y <= 1.0 && (hitAngle < PI || amount > 0.5)) {
        shado = 1.0 - (sqrt(pow(point.x - 0.5, 2.0) + pow(point.y - 0.5, 2.0)) / 0.71);
        shado *= pow(-yc / IPC_CYLINDER_RADIUS, 3.0);
        shado *= 0.5;
    } else {
        shado = 0.0;
    }
    return float4(shado, shado, shado, max(0.0, shado));
}

[[ stitchable ]]
half4 invertedPageCurl(float2 position,
                       SwiftUI::Layer layer,
                       float2 size,
                       float progress,
                       float directionRightToLeft,
                       float edgeTop) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Store original position for sampling
    float2 originalPos = position;
    // Calculate normalized UV coordinates
    float2 p = position / size;
    // Apply direction: flip horizontally for left-to-right
    if (directionRightToLeft < 0.5) {
        p.x = 1.0 - p.x;
    }
    // Apply edge: flip vertically for bottom edge
    if (edgeTop < 0.5) {
        p.y = 1.0 - p.y;
    }
    // Invert progress: SwiftUI 0=hidden,1=visible
    float amount = (1.0 - progress) * (IPC_MAX_AMOUNT - IPC_MIN_AMOUNT) + IPC_MIN_AMOUNT;
    float cylinderCenter = amount;
    float cylinderAngle = 2.0 * PI * amount;
    // Fixed angle as in original GLSL (100 degrees)
    const float angle = 100.0 * PI / 180.0;
    float c = cos(-angle);
    float s = sin(-angle);
    float3x3 rotation = float3x3(float3(c, s, 0), float3(-s, c, 0), float3(-0.801, 0.8900, 1));
    c = cos(angle);
    s = sin(angle);
    float3x3 rrotation = float3x3(float3(c, s, 0), float3(-s, c, 0), float3(0.98500, 0.985, 1));
    float3 point = rotation * float3(p, 1.0);
    float yc = point.y - cylinderCenter;
    // Behind surface
    if (yc < -IPC_CYLINDER_RADIUS) {
        return half4(ipc_behindSurface(p, yc, point, originalPos, size, layer, amount, cylinderAngle, rrotation));
    }
    // Flat surface
    if (yc > IPC_CYLINDER_RADIUS) {
        return layer.sample(originalPos);
    }
    // Curl region
    float hitAngle = (acos(yc / IPC_CYLINDER_RADIUS) + cylinderAngle) - PI;
    float hitAngleMod = fmod(hitAngle, 2.0 * PI);
    if (hitAngleMod < 0.0) hitAngleMod += 2.0 * PI;
    // See-through
    if ((hitAngleMod > PI && amount < 0.5) || (hitAngleMod > PI/2.0 && amount < 0.0)) {
        return half4(ipc_seeThrough(yc, p, originalPos, size, layer, cylinderAngle, rotation, rrotation, directionRightToLeft, edgeTop));
    }
    // Transform point
    point = ipc_hitPoint(hitAngle, yc, point, rrotation);
    // Out of bounds - see through with shadow
    if (point.x < 0.0 || point.y < 0.0 || point.x > 1.0 || point.y > 1.0) {
        return half4(ipc_seeThroughWithShadow(yc, p, point, originalPos, size, layer, amount, cylinderAngle, rotation, rrotation, directionRightToLeft, edgeTop));
    }
    // BACKSIDE: sample at transformed point with grayscale
    float4 color = ipc_backside(yc, point, size, layer, directionRightToLeft, edgeTop);
    // OTHER COLOR for antiAlias blending
    float4 otherColor;
    if (yc < 0.0) {
        // Inside curl: shadow
        float shado = 1.0 - (sqrt(pow(point.x - 0.5, 2.0) + pow(point.y - 0.5, 2.0)) / 0.71);
        shado *= pow(-yc / IPC_CYLINDER_RADIUS, 3.0);
        shado *= 0.5;
        otherColor = float4(0.0, 0.0, 0.0, shado);
    } else {
        // Outside curl: show FROM at original position
        otherColor = float4(layer.sample(originalPos));
    }
    // First blend: backside with otherColor based on distance from cylinder surface
    color = ipc_antiAlias(color, otherColor, IPC_CYLINDER_RADIUS - abs(yc));
    // Second blend: result with seeThroughWithShadow based on edge distance
    float4 cl = ipc_seeThroughWithShadow(yc, p, point, originalPos, size, layer, amount, cylinderAngle, rotation, rrotation, directionRightToLeft, edgeTop);
    float dist = ipc_distanceToEdge(point);
    color = ipc_antiAlias(color, cl, dist);
    return half4(color);
}
