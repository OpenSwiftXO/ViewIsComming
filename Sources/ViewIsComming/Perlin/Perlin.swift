import SwiftUI

// MARK: - Transition
public extension Transition where Self == PerlinTransition {
    static func perlin(
        scale: Double = 4.0,
        smoothness: Double = 0.01,
        seed: Double = 12.9898
    ) -> Self {
        PerlinTransition(
            scale: scale,
            smoothness: smoothness,
            seed: seed
        )
    }
}

public struct PerlinTransition: Transition {
    let scale: Double
    let smoothness: Double
    let seed: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            PerlinModifier(
                progress: phase.isIdentity ? 1 : 0,
                scale: scale,
                smoothness: smoothness,
                seed: seed
            )
        )
    }
}

// MARK: - Effect
struct PerlinModifier: ViewModifier {
    let progress: Double
    let scale: Double
    let smoothness: Double
    let seed: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.perlin(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(scale),
                            .float(smoothness),
                            .float(seed)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
