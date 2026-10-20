import SwiftUI

// MARK: - Transition
public extension Transition where Self == HexagonalizeTransition {
    static func hexagonalize(
        steps: Double = 50,
        horizontalHexagons: Double = 20
    ) -> Self {
        HexagonalizeTransition(
            steps: steps,
            horizontalHexagons: horizontalHexagons
        )
    }
}

public struct HexagonalizeTransition: Transition {
    let steps: Double
    let horizontalHexagons: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            HexagonalizeModifier(
                progress: phase.isIdentity ? 1 : 0,
                steps: steps,
                horizontalHexagons: horizontalHexagons
            )
        )
    }
}

// MARK: - Effect
struct HexagonalizeModifier: ViewModifier {
    let progress: Double
    let steps: Double
    let horizontalHexagons: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.hexagonalize(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(steps),
                            .float(horizontalHexagons)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1.5 / max(horizontalHexagons, 1))
                    )
            }
    }
}
