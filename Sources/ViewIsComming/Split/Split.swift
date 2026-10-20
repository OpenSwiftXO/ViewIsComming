import SwiftUI

public enum SplitAxis: Sendable {
    case horizontal
    case vertical
}

public enum SplitDirection: Sendable {
    case open
    case close
}

// MARK: - Transition
public extension Transition where Self == SplitTransition {
    static func split(
        axis: SplitAxis = .horizontal,
        direction: SplitDirection = .open,
        smoothness: Double = 0.1
    ) -> Self {
        SplitTransition(
            axis: axis,
            direction: direction,
            smoothness: smoothness
        )
    }
}

public struct SplitTransition: Transition {
    let axis: SplitAxis
    let direction: SplitDirection
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            SplitModifier(
                progress: phase.isIdentity ? 1 : 0,
                axis: axis,
                direction: direction,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct SplitModifier: ViewModifier {
    let progress: Double
    let axis: SplitAxis
    let direction: SplitDirection
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.split(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(smoothness),
                            .float(axis == .horizontal ? 1.0 : 0.0),
                            .float(direction == .open ? 1.0 : 0.0)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
