import SwiftUI

// MARK: - Transition
public extension Transition where Self == SlideTransition {
    /// A transition that slides the content in a specified direction
    /// - Parameter direction: The direction vector for sliding (default: (-1, 0) for left)
    /// - Returns: A custom transition with slide effect
    static func slide(
        direction: CGVector = CGVector(dx: -1, dy: 0)
    ) -> Self {
        SlideTransition(direction: direction)
    }
}

public struct SlideTransition: Transition {
    let direction: CGVector
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            SlideModifier(
                progress: phase.isIdentity ? 1 : 0,
                direction: direction
            )
        )
    }
}

// MARK: - Effect
struct SlideModifier: ViewModifier {
    let progress: Double
    let direction: CGVector
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.slide(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float2(Float(direction.dx), Float(direction.dy))
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
