import SwiftUI

public enum InvertedPageCurlDirection: Sendable {
    case leftToRight
    case rightToLeft
}

public enum InvertedPageCurlEdge: Sendable {
    case top
    case bottom
}

// MARK: - Transition
public extension Transition where Self == InvertedPageCurlTransition {
    static func invertedPageCurl(
        direction: InvertedPageCurlDirection = .rightToLeft,
        edge: InvertedPageCurlEdge = .top
    ) -> Self {
        InvertedPageCurlTransition(direction: direction, edge: edge)
    }
}

public struct InvertedPageCurlTransition: Transition {
    let direction: InvertedPageCurlDirection
    let edge: InvertedPageCurlEdge
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            InvertedPageCurlModifier(
                progress: phase.isIdentity ? 1 : 0,
                direction: direction,
                edge: edge
            )
        )
    }
}

// MARK: - Effect
struct InvertedPageCurlModifier: ViewModifier {
    let progress: Double
    let direction: InvertedPageCurlDirection
    let edge: InvertedPageCurlEdge
    
    func body(content: Content) -> some View {
        let directionValue = direction == .rightToLeft ? 1.0 : 0.0
        let edgeValue = edge == .top ? 1.0 : 0.0
        
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.invertedPageCurl(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(directionValue),
                            .float(edgeValue)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
