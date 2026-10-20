import SwiftUI

// MARK: - Transition
public extension Transition where Self == LumaTransition {
    static func luma(
        patternScale: Double = 3.0
    ) -> Self {
        LumaTransition(patternScale: patternScale)
    }
}

public struct LumaTransition: Transition {
    let patternScale: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            LumaModifier(
                progress: phase.isIdentity ? 1 : 0,
                patternScale: patternScale
            )
        )
    }
}

// MARK: - Effect
struct LumaModifier: ViewModifier {
    let progress: Double
    let patternScale: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.luma(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(patternScale)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
