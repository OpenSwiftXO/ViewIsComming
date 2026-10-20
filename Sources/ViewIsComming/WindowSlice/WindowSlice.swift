import SwiftUI

// MARK: - Transition
public extension Transition where Self == WindowSliceTransition {
    static func windowSlice(
        count: Double = 10.0,
        smoothness: Double = 0.5
    ) -> Self {
        WindowSliceTransition(
            count: count,
            smoothness: smoothness
        )
    }
}

public struct WindowSliceTransition: Transition {
    let count: Double
    let smoothness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            WindowSliceModifier(
                progress: phase.isIdentity ? 1 : 0,
                count: count,
                smoothness: smoothness
            )
        )
    }
}

// MARK: - Effect
struct WindowSliceModifier: ViewModifier {
    let progress: Double
    let count: Double
    let smoothness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.windowSlice(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(count),
                            .float(smoothness)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
