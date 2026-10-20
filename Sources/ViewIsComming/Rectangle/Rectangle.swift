import SwiftUI

// MARK: - Transition
public extension Transition where Self == RectangleTransition {
    static var rectangle: Self {
        RectangleTransition()
    }
}

public struct RectangleTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            RectangleModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct RectangleModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.rectangle(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
