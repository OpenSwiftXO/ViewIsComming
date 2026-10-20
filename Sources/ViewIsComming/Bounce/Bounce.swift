import SwiftUI

// MARK: - Direction
public enum BounceDirection: Sendable {
    case `in`
    case out
    
    var floatValue: Float {
        switch self {
        case .in: return 1.0
        case .out: return 0.0
        }
    }
}

// MARK: - Transition
public extension Transition where Self == AsymmetricTransition<BounceTransition, BounceTransition> {
    /// The view drops in with a few bounces and drops out of the frame again when it is removed.
    /// - Parameter bounces: Number of bounces before the view settles (default: 4.0)
    static func bounce(
        bounces: Double = 4.0
    ) -> Self {
        AsymmetricTransition(
            insertion: BounceTransition(bounces: bounces, direction: .in),
            removal: BounceTransition(bounces: bounces, direction: .out)
        )
    }
}

public extension Transition where Self == BounceTransition {
    static func bounceIn(
        bounces: Double = 4.0
    ) -> Self {
        BounceTransition(
            bounces: bounces,
            direction: .in
        )
    }
    
    static func bounceOut(
        bounces: Double = 4.0
    ) -> Self {
        BounceTransition(
            bounces: bounces,
            direction: .out
        )
    }
}

public struct BounceTransition: Transition {
    let bounces: Double
    let direction: BounceDirection
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        // Insertion plays towards progress 1, removal towards progress 0.
        let visible = direction == .in ? 1.0 : 0.0
        return content.modifier(
            BounceModifier(
                progress: phase.isIdentity ? visible : 1.0 - visible,
                bounces: bounces,
                direction: direction
            )
        )
    }
}

// MARK: - Effect
struct BounceModifier: ViewModifier {
    let progress: Double
    let bounces: Double
    let direction: BounceDirection
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.bounce(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(bounces),
                            .float(direction.floatValue)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(x: 0, y: 1)
                    )
            }
    }
}
