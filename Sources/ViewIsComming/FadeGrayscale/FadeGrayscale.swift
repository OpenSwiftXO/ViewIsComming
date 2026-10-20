import SwiftUI

// MARK: - Transition
public extension Transition where Self == FadeGrayscaleTransition {
    static func fadeGrayscale(
        intensity: Double = 0.3
    ) -> Self {
        FadeGrayscaleTransition(intensity: intensity)
    }
}

public struct FadeGrayscaleTransition: Transition {
    let intensity: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            FadeGrayscaleModifier(
                progress: phase.isIdentity ? 1 : 0,
                intensity: intensity
            )
        )
    }
}

// MARK: - Effect
struct FadeGrayscaleModifier: ViewModifier {
    let progress: Double
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.fadeGrayscale(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(intensity)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
