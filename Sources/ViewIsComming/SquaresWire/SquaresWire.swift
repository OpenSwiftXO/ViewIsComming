import SwiftUI

public enum SquaresWireDirection {
    case right
    case left
    case down
    case up
    case downRight
    case downLeft
    case upRight
    case upLeft
    
    var vector: CGPoint {
        switch self {
        case .right:        return CGPoint(x: 1.0, y: 0.0)
        case .left:         return CGPoint(x: -1.0, y: 0.0)
        case .down:         return CGPoint(x: 0.0, y: 1.0)
        case .up:           return CGPoint(x: 0.0, y: -1.0)
        case .downRight:    return CGPoint(x: 1.0, y: 1.0)
        case .downLeft:     return CGPoint(x: -1.0, y: 1.0)
        case .upRight:      return CGPoint(x: 1.0, y: -1.0)
        case .upLeft:       return CGPoint(x: -1.0, y: -1.0)
        }
    }
}

// MARK: - Transition
public extension Transition where Self == SquaresWireTransition {
    static func squaresWire(
        squares: Int = 10,
        direction: SquaresWireDirection = .upRight,
        smoothness: Double = 1.6
    ) -> Self {
        SquaresWireTransition(
            squares: squares,
            direction: direction.vector,
            smoothness: smoothness
        )
    }
}

public struct SquaresWireTransition: Transition {
    let squares: Int
    let direction: CGPoint
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            SquaresWireModifier(
                progress: phase.isIdentity ? 1 : 0,
                squares: squares,
                direction: direction,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct SquaresWireModifier: ViewModifier {
    let progress: Double
    let squares: Int
    let direction: CGPoint
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.squaresWire(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float2(Float(squares), Float(squares)),
                            .float2(Float(direction.x), Float(direction.y)),
                            .float(smoothness)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
