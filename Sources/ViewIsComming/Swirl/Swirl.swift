import SwiftUI

// MARK: - Transition
public extension Transition where Self == SwirlTransition {
    static var swirl: Self {
        SwirlTransition()
    }
}

public struct SwirlTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            SwirlModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct SwirlModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.swirl(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
