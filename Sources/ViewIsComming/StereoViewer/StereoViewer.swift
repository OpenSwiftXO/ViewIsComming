import SwiftUI

// MARK: - Transition
public extension Transition where Self == StereoViewerTransition {
    static func stereoViewer(
        zoom: Double = 0.88,
        cornerRadius: Double = 0.22
    ) -> Self {
        StereoViewerTransition(
            zoom: zoom,
            cornerRadius: cornerRadius
        )
    }
}

public struct StereoViewerTransition: Transition {
    let zoom: Double
    let cornerRadius: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            StereoViewerModifier(
                progress: phase.isIdentity ? 1 : 0,
                zoom: zoom,
                cornerRadius: cornerRadius
            )
        )
    }
}

// MARK: - Effect
struct StereoViewerModifier: ViewModifier {
    let progress: Double
    let zoom: Double
    let cornerRadius: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.stereoViewer(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(zoom),
                            .float(cornerRadius)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
