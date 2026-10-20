#include <metal_stdlib>
using namespace metal;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-function"

// π
constant float PI = 3.141592653589793;

// GLSL's mod(): x - y * floor(x / y). Unlike fmod() the result takes the sign
// of `y`, which the gl-transitions ports rely on for negative coordinates.
static inline float glslMod(float x, float y) {
    return x - y * floor(x / y);
}

static inline float2 glslMod(float2 x, float y) {
    return x - y * floor(x / y);
}

#pragma clang diagnostic pop
