import SwiftUI

// MARK: - Transition
public extension Transition where Self == RadialTransition {
    /// Radial wipe transition based on angle
    /// - Parameter smoothness: Controls the edge smoothness of the wipe (default: 1.0)
    static func radial(smoothness: Double = 1.0) -> Self {
        RadialTransition(smoothness: smoothness)
    }
}

public struct RadialTransition: Transition {
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            RadialModifier(
                progress: phase.isIdentity ? 1 : 0,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct RadialModifier: ViewModifier {
    let progress: Double
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.radial(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(smoothness)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
