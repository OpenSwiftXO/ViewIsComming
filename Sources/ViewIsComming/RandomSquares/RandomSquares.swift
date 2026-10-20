import SwiftUI

// MARK: - Transition
public extension Transition where Self == RandomSquaresTransition {
    static func randomSquares(
        size: CGSize = CGSize(width: 10, height: 10),
        smoothness: Double = 0.5
    ) -> Self {
        RandomSquaresTransition(
            size: size,
            smoothness: smoothness
        )
    }
}

public struct RandomSquaresTransition: Transition {
    let size: CGSize
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            RandomSquaresModifier(
                progress: phase.isIdentity ? 1 : 0,
                size: size,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct RandomSquaresModifier: ViewModifier {
    let progress: Double
    let size: CGSize
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.randomSquares(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float2(Float(size.width), Float(size.height)),
                            .float(smoothness)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
