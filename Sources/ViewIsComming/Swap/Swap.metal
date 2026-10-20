#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

float2 swapProject(float2 p) {
    return p * float2(1.0, -1.2) + float2(0.0, 2.02);
}

[[ stitchable ]]
half4 swap(float2 position,
           SwiftUI::Layer layer,
           float2 size,
           float progress,
           float reflection,
           float perspective,
           float depth,
           float swapRight) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Mirror for left swap
    bool isSwapRight = swapRight > 0.5;
    float2 workingUV = isSwapRight ? uv : float2(1.0 - uv.x, uv.y);
    float2 pfr = float2(-1.0);
    float2 pto = float2(-1.0);
    // Calculate "from" face position (left side, disappearing)
    float size1 = mix(1.0, depth, progress);
    float persp1 = perspective * progress;
    pfr = (workingUV + float2(-0.0, -0.5)) * float2(size1 / (1.0 - perspective * progress), size1 / (1.0 - size1 * persp1 * workingUV.x)) + float2(0.0, 0.5);
    // Calculate "to" face position (right side, appearing)
    float size2 = mix(1.0, depth, 1.0 - progress);
    float persp2 = perspective * (1.0 - progress);
    pto = (workingUV + float2(-1.0, -0.5)) * float2(size2 / (1.0 - perspective * (1.0 - progress)), size2 / (1.0 - size2 * persp2 * (0.5 - workingUV.x))) + float2(1.0, 0.5);
    // Check bounds
    bool pfrInBounds = pfr.x >= 0.0 && pfr.x <= 1.0 && pfr.y >= 0.0 && pfr.y <= 1.0;
    bool ptoInBounds = pto.x >= 0.0 && pto.x <= 1.0 && pto.y >= 0.0 && pto.y <= 1.0;
    float mask = 0.0;
    float2 sampleUV = uv;
    half4 color = half4(0.0);
    // CRITICAL: We are the "to" view (appearing view)
    // if (progress < 0.5) → check pfr first (from has priority), then pto
    // else → check pto first (to has priority), then pfr
    // Background reflection for faces that are out of bounds
    if (progress < 0.5) {
        // First half: "from" face has priority
        if (pfrInBounds) {
            // "From" face is visible - we are NOT this face, so hide
            mask = 0.0;
        } else if (ptoInBounds) {
            // "To" face is visible - this is us appearing
            float2 finalUV = isSwapRight ? pto : float2(1.0 - pto.x, pto.y);
            sampleUV = finalUV;
            color = layer.sample(sampleUV * size);
            mask = 1.0;
        } else {
            // Neither face visible, show reflection of "to" face
            float2 ptoProjected = swapProject(pto);
            bool ptoProjectedInBounds = ptoProjected.x >= 0.0 && ptoProjected.x <= 1.0 && ptoProjected.y >= 0.0 && ptoProjected.y <= 1.0;
            if (ptoProjectedInBounds) {
                float2 finalUV = isSwapRight ? ptoProjected : float2(1.0 - ptoProjected.x, ptoProjected.y);
                sampleUV = finalUV;
                color = layer.sample(sampleUV * size);
                // After project() flips Y: bright at bottom, fade to dark at top
                float reflectionStrength = reflection * mix(1.0, 0.0, ptoProjected.y);
                mask = reflectionStrength;
            }
        }
    } else {
        // Second half: "to" face has priority
        if (ptoInBounds) {
            // "To" face is visible - this is us, the main face
            float2 finalUV = isSwapRight ? pto : float2(1.0 - pto.x, pto.y);
            sampleUV = finalUV;
            color = layer.sample(sampleUV * size);
            mask = 1.0;
        } else if (pfrInBounds) {
            // "From" face is visible - we are NOT this face, so hide
            mask = 0.0;
        } else {
            // Neither face visible, show reflection of "to" face
            float2 ptoProjected = swapProject(pto);
            bool ptoProjectedInBounds = ptoProjected.x >= 0.0 && ptoProjected.x <= 1.0 && ptoProjected.y >= 0.0 && ptoProjected.y <= 1.0;
            if (ptoProjectedInBounds) {
                float2 finalUV = isSwapRight ? ptoProjected : float2(1.0 - ptoProjected.x, ptoProjected.y);
                sampleUV = finalUV;
                color = layer.sample(sampleUV * size);
                // After projection flips Y, gradient needs to be reversed
                // Darker at bottom (high y after flip), brighter at top (low y after flip)
                float reflectionStrength = reflection * mix(1.0, 0.0, ptoProjected.y);
                mask = reflectionStrength;
            }
        }
    }
    
    return color * half(mask);
}
