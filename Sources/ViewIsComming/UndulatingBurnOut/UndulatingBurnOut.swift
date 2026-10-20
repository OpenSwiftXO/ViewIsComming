import SwiftUI

// MARK: - Transition
public extension Transition where Self == UndulatingBurnOutTransition {
    static func undulatingBurnOut(
        smoothness: Double = 0.03,
        center: CGPoint = CGPoint(x: 0.5, y: 0.5)
    ) -> Self {
        UndulatingBurnOutTransition(
            smoothness: smoothness,
            center: center
        )
    }
}

public struct UndulatingBurnOutTransition: Transition {
    let smoothness: Double
    let center: CGPoint
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            UndulatingBurnOutModifier(
                progress: phase.isIdentity ? 1 : 0,
                smoothness: smoothness,
                center: center
            )
        )
    }
}

// MARK: - Effect
struct UndulatingBurnOutModifier: ViewModifier {
    let progress: Double
    let smoothness: Double
    let center: CGPoint
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.undulatingBurnOut(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(smoothness),
                            .float2(Float(center.x), Float(center.y))
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
