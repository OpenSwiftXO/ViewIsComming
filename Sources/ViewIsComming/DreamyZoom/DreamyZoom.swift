import SwiftUI

// MARK: - Transition
public extension Transition where Self == DreamyZoomTransition {
    static func dreamyZoom(
        rotation: Double = 0.0,
        scale: Double = 2.0
    ) -> Self {
        DreamyZoomTransition(
            rotation: rotation,
            scale: scale
        )
    }
}

public struct DreamyZoomTransition: Transition {
    let rotation: Double
    let scale: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            DreamyZoomModifier(
                progress: phase.isIdentity ? 1 : 0,
                rotation: rotation,
                scale: scale
            )
        )
    }
}

// MARK: - Effect
struct DreamyZoomModifier: ViewModifier {
    let progress: Double
    let rotation: Double
    let scale: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.dreamyZoom(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(rotation),
                            .float(scale)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
