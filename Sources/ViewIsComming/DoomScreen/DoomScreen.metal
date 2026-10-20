#include <SwiftUI/SwiftUI_Metal.h>
#include <metal_stdlib>
using namespace metal;

// Helper function for doom random (pseudo-random based on coordinates)
// This creates different values for each bar, but same pattern each time
float doomScreen_rand(float2 co) {
    return fract(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

[[ stitchable ]]
half4 doomScreen(float2 position,
                 SwiftUI::Layer layer,
                 float2 size,
                 float progress,
                 float barsFloat,
                 float amplitude,
                 float noise,
                 float frequency,
                 float dripScale) {
    // Resting state: nothing to do once the transition has completed.
    if (progress >= 1.0) {
        return layer.sample(position);
    }

    // Normalize coordinates
    float2 uv = position / size;
    // Early return for fully visible state (optimization)
    if (progress >= 0.999) {
        return layer.sample(position);
    }
    // Cast float to int for bars
    int bars = int(barsFloat);
    // Calculate bar index (clamp to valid range)
    int barIndex = clamp(int(uv.x * float(bars)), 0, bars - 1);
    // Wave function
    float fn = float(barIndex) * frequency * 0.1 * float(bars);
    float waveValue = cos(fn * 0.5) * cos(fn * 0.13) * sin((fn + 10.0) * 0.3) / 2.0 + 0.5;
    // Random value for this bar (deterministic - same pattern each time)
    float randomValue = doomScreen_rand(float2(float(barIndex), 0.0));
    // Drip effect (curved falling from center - avoid division by zero)
    float dripValue = 0.0;
    if (bars > 1) {
        dripValue = sin(float(barIndex) / float(bars - 1) * 3.14159) * dripScale;
    }
    // Position offset: mix wave pattern with random, then add drip curve
    float barOffset = mix(waveValue, randomValue, noise) + dripValue;
    // Scale determines how fast this bar melts (based on offset and amplitude)
    // Clamp to reasonable range to avoid extreme values
    float meltSpeed = clamp(1.0 + barOffset * amplitude, 0.5, 10.0);
    // Invert progress: 1.0 = visible (no melt), 0.0 = hidden (fully melted)
    float meltPhase = (1.0 - progress) * meltSpeed;
    // Calculate sample position
    // We sample from above (subtract from Y) so content appears to fall down
    float2 sampleUV = uv;
    sampleUV.y = uv.y - meltPhase;
    // Calculate visibility mask
    // When progress = 1.0 -> meltPhase = 0 -> sampleUV = uv -> fully visible
    // When progress = 0.0 -> meltPhase large -> sampleUV.y negative -> hidden
    float mask = (sampleUV.y >= 0.0 && sampleUV.y <= 1.0) ? 1.0 : 0.0;
    
    // Sample the layer at the calculated position
    half4 color = layer.sample(sampleUV * size);
    return color * half(mask);
}
