import SwiftUI

// MARK: - Transition
public extension Transition where Self == CircleCropTransition {
    static func circleCrop(
        smoothness: Double = 0.3
    ) -> Self {
        CircleCropTransition(
            smoothness: smoothness
        )
    }
}

public struct CircleCropTransition: Transition {
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            CircleCropModifier(
                progress: phase.isIdentity ? 1 : 0,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct CircleCropModifier: ViewModifier {
    let progress: Double
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.circleCrop(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(smoothness)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
