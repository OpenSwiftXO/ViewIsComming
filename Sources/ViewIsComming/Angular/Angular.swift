import SwiftUI

// MARK: - Transition
public extension Transition where Self == AngularTransition {
    static func angular(
        startingAngle: Angle = .degrees(90),
        clockwise: Bool = true
    ) -> Self {
        AngularTransition(
            startingAngle: startingAngle,
            clockwise: clockwise
        )
    }
}

public struct AngularTransition: Transition {
    let startingAngle: Angle
    let clockwise: Bool
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            AngularModifier(
                progress: phase.isIdentity ? 1 : 0,
                startingAngle: startingAngle,
                clockwise: clockwise
            )
        )
    }
}

// MARK: - Effect
struct AngularModifier: ViewModifier {
    let progress: Double
    let startingAngle: Angle
    let clockwise: Bool
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.angular(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(startingAngle.degrees),
                            .float(clockwise ? 1.0 : 0.0)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
