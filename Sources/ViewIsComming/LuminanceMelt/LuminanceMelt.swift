import SwiftUI

// MARK: - Transition
public extension Transition where Self == LuminanceMeltTransition {
    static func luminanceMelt(
        direction: Double = 1.0,
        threshold: Double = 0.5,
        smoothness: Double = 0.1
    ) -> Self {
        LuminanceMeltTransition(
            direction: direction,
            threshold: threshold,
            smoothness: smoothness
        )
    }
}

public struct LuminanceMeltTransition: Transition {
    let direction: Double
    let threshold: Double
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            LuminanceMeltModifier(
                progress: phase.isIdentity ? 1 : 0,
                direction: direction,
                threshold: threshold,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct LuminanceMeltModifier: ViewModifier {
    let progress: Double
    let direction: Double
    let threshold: Double
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.luminanceMelt(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(direction),
                            .float(threshold),
                            .float(smoothness)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
