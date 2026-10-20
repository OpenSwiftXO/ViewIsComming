import SwiftUI

// MARK: - Transition
public extension Transition where Self == WindowBlindsTransition {
    static var windowBlinds: Self {
        WindowBlindsTransition()
    }
}

public struct WindowBlindsTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            WindowBlindsModifier(
                progress: phase.isIdentity ? 1 : 0
            )
        )
    }
}

// MARK: - Effect
struct WindowBlindsModifier: ViewModifier {
    let progress: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.windowBlinds(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
