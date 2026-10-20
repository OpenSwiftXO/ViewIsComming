import SwiftUI

// MARK: - Transition
public extension Transition where Self == SimpleZoomTransition {
    static func simpleZoom(
        zoomQuickness: Double = 0.8
    ) -> Self {
        SimpleZoomTransition(zoomQuickness: zoomQuickness)
    }
}

public struct SimpleZoomTransition: Transition {
    let zoomQuickness: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            SimpleZoomModifier(
                progress: phase.isIdentity ? 1 : 0,
                zoomQuickness: zoomQuickness
            )
        )
    }
}

// MARK: - Effect
struct SimpleZoomModifier: ViewModifier {
    let progress: Double
    let zoomQuickness: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.simpleZoom(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(zoomQuickness)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(0.5)
                    )
            }
    }
}
