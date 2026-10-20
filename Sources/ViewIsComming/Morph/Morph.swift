import SwiftUI

// MARK: - Transition
public extension Transition where Self == MorphTransition {
    /// A transition that morphs the content based on its colors
    /// - Parameter strength: The strength of the morphing effect (default: 0.1)
    /// - Returns: A custom transition with morphing distortion
    static func morph(
        strength: Double = 0.1
    ) -> Self {
        MorphTransition(strength: strength)
    }
}

public struct MorphTransition: Transition {
    let strength: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            MorphModifier(
                progress: phase.isIdentity ? 1 : 0,
                strength: strength
            )
        )
    }
}

// MARK: - Effect
struct MorphModifier: ViewModifier {
    let progress: Double
    let strength: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.morph(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(strength)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(abs(strength))
                    )
            }
    }
}
