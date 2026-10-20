import SwiftUI

// MARK: - Transition
public extension Transition where Self == PolarFunctionTransition {
    static func polarFunction(
        segments: Double = 5.0
    ) -> Self {
        PolarFunctionTransition(segments: segments)
    }
}

public struct PolarFunctionTransition: Transition {
    let segments: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            PolarFunctionModifier(
                progress: phase.isIdentity ? 1 : 0,
                segments: segments
            )
        )
    }
}

// MARK: - Effect
struct PolarFunctionModifier: ViewModifier {
    let progress: Double
    let segments: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.polarFunction(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(segments)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
