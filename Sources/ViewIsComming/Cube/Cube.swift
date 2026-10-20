import SwiftUI

// MARK: - Transition
public extension Transition where Self == CubeTransition {
    static func cube(
        perspective: Double = 0.7,
        unzoom: Double = 0.3,
        rotateRight: Bool = true
    ) -> Self {
        CubeTransition(
            perspective: perspective,
            unzoom: unzoom,
            rotateRight: rotateRight
        )
    }
}

public struct CubeTransition: Transition {
    let perspective: Double
    let unzoom: Double
    let rotateRight: Bool
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            CubeModifier(
                progress: phase.isIdentity ? 1 : 0,
                perspective: perspective,
                unzoom: unzoom,
                rotateRight: rotateRight
            )
        )
    }
}

// MARK: - Effect
struct CubeModifier: ViewModifier {
    let progress: Double
    let perspective: Double
    let unzoom: Double
    let rotateRight: Bool
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.cube(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(perspective),
                            .float(unzoom),
                            .float(rotateRight ? 1.0 : 0.0)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
