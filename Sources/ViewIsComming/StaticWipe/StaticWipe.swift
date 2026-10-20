import SwiftUI

// MARK: - Transition
public extension Transition where Self == StaticWipeTransition {
    static func staticWipe(
        upToDown: Bool = true,
        maximumStatic: Double = 0.5,
        staticFade: Double = 0.15
    ) -> Self {
        StaticWipeTransition(
            upToDown: upToDown,
            maximumStatic: maximumStatic,
            staticFade: staticFade
        )
    }
}

public struct StaticWipeTransition: Transition {
    let upToDown: Bool
    let maximumStatic: Double
    let staticFade: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            StaticWipeModifier(
                progress: phase.isIdentity ? 1 : 0,
                upToDown: upToDown,
                maximumStatic: maximumStatic,
                staticFade: staticFade
            )
        )
    }
}

// MARK: - Effect
struct StaticWipeModifier: ViewModifier {
    let progress: Double
    let upToDown: Bool
    let maximumStatic: Double
    let staticFade: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.staticWipe(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(upToDown ? 1.0 : 0.0),
                            .float(maximumStatic),
                            .float(staticFade)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
