import SwiftUI

public enum WindDirection: Sendable {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
    
    var rawValue: Float {
        switch self {
        case .leftToRight: return 0
        case .rightToLeft: return 1
        case .topToBottom: return 2
        case .bottomToTop: return 3
        }
    }
}

// MARK: - Transition
public extension Transition where Self == WindTransition {
    static func wind(
        windSize: Double = 0.2,
        direction: WindDirection = .leftToRight
    ) -> Self {
        WindTransition(
            windSize: windSize,
            direction: direction
        )
    }
}

public struct WindTransition: Transition {
    let windSize: Double
    let direction: WindDirection
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            WindModifier(
                progress: phase.isIdentity ? 1 : 0,
                windSize: windSize,
                direction: direction
            )
        )
    }
}

// MARK: - Effect
struct WindModifier: ViewModifier {
    let progress: Double
    let windSize: Double
    let direction: WindDirection
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.wind(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(windSize),
                            .float(direction.rawValue)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
