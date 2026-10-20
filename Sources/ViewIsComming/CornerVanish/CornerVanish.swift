import SwiftUI

public enum Corner: Float, CaseIterable, Sendable {
    case topLeft = 0
    case topRight = 1
    case bottomRight = 2
    case bottomLeft = 3
}

// MARK: - Transition
public extension Transition where Self == CornerVanishTransition {
    static func cornerVanish(
        smoothness: Double = 0.3,
        corner: Corner = .topLeft
    ) -> Self {
        CornerVanishTransition(
            smoothness: smoothness,
            corner: corner
        )
    }
}

public struct CornerVanishTransition: Transition {
    let smoothness: Double
    let corner: Corner
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            CornerVanishModifier(
                progress: phase.isIdentity ? 1 : 0,
                smoothness: smoothness,
                corner: corner
            )
        )
    }
}

// MARK: - Effect
struct CornerVanishModifier: ViewModifier {
    let progress: Double
    let smoothness: Double
    let corner: Corner
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.cornerVanish(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(smoothness),
                            .float(corner.rawValue)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
