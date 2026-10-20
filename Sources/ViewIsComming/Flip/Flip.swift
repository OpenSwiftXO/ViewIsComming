import SwiftUI

// MARK: - Transition
public extension Transition where Self == FlipTransition {
    /// A transition that creates a 3D flip effect.
    ///
    /// - Parameters:
    ///   - axis: Flip axis (0.0 = horizontal, 1.0 = vertical). Default is 0.0.
    ///   - perspective: Perspective strength (0.0 to 2.0). Default is 0.5.
    /// - Returns: A transition that creates a flip effect.
    static func flip(
        axis: Double = 0.0,
        perspective: Double = 0.5
    ) -> Self {
        FlipTransition(
            axis: axis,
            perspective: perspective
        )
    }
}

public struct FlipTransition: Transition {
    let axis: Double
    let perspective: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            FlipModifier(
                progress: phase.isIdentity ? 1 : 0,
                axis: axis,
                perspective: perspective
            )
        )
    }
}

// MARK: - Effect
struct FlipModifier: ViewModifier {
    let progress: Double
    let axis: Double
    let perspective: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.flip(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(axis),
                            .float(perspective)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
