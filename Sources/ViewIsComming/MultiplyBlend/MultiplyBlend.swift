import SwiftUI

// MARK: - Transition
public extension Transition where Self == MultiplyBlendTransition {
    /// A transition that creates a multiply blend effect.
    ///
    /// - Parameter intensity: Blend intensity (0.0 to 2.0). Default is 1.0.
    /// - Returns: A transition that creates a multiply blend effect.
    static func multiplyBlend(
        intensity: Double = 1.0
    ) -> Self {
        MultiplyBlendTransition(intensity: intensity)
    }
}

public struct MultiplyBlendTransition: Transition {
    let intensity: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            MultiplyBlendModifier(
                progress: phase.isIdentity ? 1 : 0,
                intensity: intensity
            )
        )
    }
}

// MARK: - Effect
struct MultiplyBlendModifier: ViewModifier {
    let progress: Double
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.multiplyBlend(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(intensity)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
