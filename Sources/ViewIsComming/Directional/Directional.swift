import SwiftUI

public enum DirectionalDirection {
    case up
    case down
    case left
    case right
    
    public var opposite: DirectionalDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
    
    var vector: CGVector {
        switch self {
        case .up: return CGVector(dx: 0, dy: -1)
        case .down: return CGVector(dx: 0, dy: 1)
        case .left: return CGVector(dx: -1, dy: 0)
        case .right: return CGVector(dx: 1, dy: 0)
        }
    }
}

// MARK: - Transition
public extension Transition where Self == DirectionalTransition {
    static func directional(direction: DirectionalDirection = .right) -> Self {
        DirectionalTransition(direction: direction.vector)
    }
}

public struct DirectionalTransition: Transition {
    let direction: CGVector
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            DirectionalModifier(
                progress: phase.isIdentity ? 1 : 0,
                direction: direction
            )
        )
    }
}

// MARK: - Effect
struct DirectionalModifier: ViewModifier {
    let progress: Double
    let direction: CGVector
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.directional(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float2(Float(direction.dx), Float(direction.dy))
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
