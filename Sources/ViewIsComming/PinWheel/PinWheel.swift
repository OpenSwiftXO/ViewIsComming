import SwiftUI

// MARK: - Transition
public extension Transition where Self == PinWheelTransition {
    static func pinWheel(
        blades: Int = 8
    ) -> Self {
        PinWheelTransition(
            blades: blades
        )
    }
}

public struct PinWheelTransition: Transition {
    let blades: Int
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            PinWheelModifier(
                progress: phase.isIdentity ? 1 : 0,
                blades: blades
            )
        )
    }
}

// MARK: - Effect
struct PinWheelModifier: ViewModifier {
    let progress: Double
    let blades: Int
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.pinWheel(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(Float(blades))
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
