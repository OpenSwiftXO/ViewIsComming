import SwiftUI

public enum BookFlipDirection: Sendable {
    case left
    case right
    
    public var opposite: BookFlipDirection {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}

// MARK: - Transition
public extension Transition where Self == BookFlipTransition {
    static func bookFlip(direction: BookFlipDirection = .right) -> Self {
        BookFlipTransition(direction: direction)
    }
}

public struct BookFlipTransition: Transition {
    let direction: BookFlipDirection
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            BookFlipModifier(
                progress: phase.isIdentity ? 1 : 0,
                direction: direction
            )
        )
    }
}

// MARK: - Effect
struct BookFlipModifier: ViewModifier {
    let progress: Double
    let direction: BookFlipDirection
    
    func body(content: Content) -> some View {
        let flipRight = direction == .right ? 1.0 : 0.0
        
        return content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.bookFlip(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(flipRight)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
