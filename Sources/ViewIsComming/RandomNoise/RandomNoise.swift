import SwiftUI

// MARK: - Transition
public extension Transition where Self == RandomNoiseTransition {
    static var randomNoise: Self {
        RandomNoiseTransition()
    }
}

public struct RandomNoiseTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            RandomNoiseModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct RandomNoiseModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.randomNoise(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
