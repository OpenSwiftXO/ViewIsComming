import SwiftUI

// MARK: - Transition
public extension Transition where Self == PixelizeTransition {
    /// A transition that pixelates the content with increasing then decreasing pixel size
    /// - Parameters:
    ///   - squaresMin: Number of squares per axis at the strongest pixelation (default: 20.0)
    ///   - steps: Number of discrete steps in the animation (default: 20.0, use -1.0 for smooth)
    /// - Returns: A custom transition with pixelization effect
    static func pixelize(
        squaresMin: Double = 20.0,
        steps: Double = 20.0
    ) -> Self {
        PixelizeTransition(
            squaresMin: squaresMin,
            steps: steps
        )
    }
}

public struct PixelizeTransition: Transition {
    let squaresMin: Double
    let steps: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            PixelizeModifier(
                progress: phase.isIdentity ? 1 : 0,
                squaresMin: squaresMin,
                steps: steps
            )
        )
    }
}

// MARK: - Effect
struct PixelizeModifier: ViewModifier {
    let progress: Double
    let squaresMin: Double
    let steps: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.pixelize(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(squaresMin),
                            .float(steps)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1 / max(squaresMin, 1))
                    )
            }
    }
}
