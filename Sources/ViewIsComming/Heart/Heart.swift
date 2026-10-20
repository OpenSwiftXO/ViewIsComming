import SwiftUI

// MARK: - Transition
public extension Transition where Self == HeartTransition {
    /// A transition that reveals content through an expanding heart shape
    /// - Returns: A custom transition with heart shape reveal
    static var heart: Self {
        HeartTransition()
    }
}

public struct HeartTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            HeartModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct HeartModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.heart(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
