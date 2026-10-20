import SwiftUI

// MARK: - Transition
public extension Transition where Self == LinearBlurTransition {
    /// A transition that applies a horizontal linear blur that peaks in the middle
    /// - Parameter intensity: The maximum blur amount (default: 0.1)
    /// - Returns: A custom transition with linear blur effect
    static func linearBlur(
        intensity: Double = 0.1
    ) -> Self {
        LinearBlurTransition(intensity: intensity)
    }
}

public struct LinearBlurTransition: Transition {
    let intensity: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            LinearBlurModifier(
                progress: phase.isIdentity ? 1 : 0,
                intensity: intensity
            )
        )
    }
}

// MARK: - Effect
struct LinearBlurModifier: ViewModifier {
    let progress: Double
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.linearBlur(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(intensity)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(abs(intensity) * 0.3)
                    )
            }
    }
}
