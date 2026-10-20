import SwiftUI

// MARK: - Transition
public extension Transition where Self == GlitchMemoriesTransition {
    static var glitchMemories: Self {
        GlitchMemoriesTransition()
    }
}

public struct GlitchMemoriesTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            GlitchMemoriesModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct GlitchMemoriesModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.glitchMemories(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(0.1)
                    )
            }
    }
}
