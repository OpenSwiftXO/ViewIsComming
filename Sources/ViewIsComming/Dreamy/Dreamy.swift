import SwiftUI

// MARK: - Transition
public extension Transition where Self == DreamyTransition {
    /// A transition that creates a dreamy, blurred effect that peaks in the middle
    /// - Returns: A custom transition with dreamy blur distortion
    static var dreamy: Self {
        DreamyTransition()
    }
}

public struct DreamyTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            DreamyModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct DreamyModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.dreamy(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(x: 0, y: 0.04)
                    )
            }
    }
}
