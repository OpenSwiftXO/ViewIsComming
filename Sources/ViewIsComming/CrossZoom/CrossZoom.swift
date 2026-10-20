import SwiftUI

// MARK: - Transition
public extension Transition where Self == CrossZoomTransition {
    static func crossZoom(
        strength: Double = 0.4
    ) -> Self {
        CrossZoomTransition(strength: strength)
    }
}

public struct CrossZoomTransition: Transition {
    let strength: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            CrossZoomModifier(
                progress: phase.isIdentity ? 1 : 0,
                strength: strength
            )
        )
    }
}

// MARK: - Effect
struct CrossZoomModifier: ViewModifier {
    let progress: Double
    let strength: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.crossZoom(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(strength)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(abs(strength))
                    )
            }
    }
}
