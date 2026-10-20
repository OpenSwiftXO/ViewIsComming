import SwiftUI

// MARK: - Transition
public extension Transition where Self == MosaicTransition {
    /// A transition that breaks the image into mosaic tiles that disappear randomly
    /// - Parameters:
    ///   - endX: Number of horizontal tiles (default: 10)
    ///   - endY: Number of vertical tiles (default: 10)
    /// - Returns: A custom transition with mosaic effect
    static func mosaic(
        endX: Int = 10,
        endY: Int = 10
    ) -> Self {
        MosaicTransition(endX: endX, endY: endY)
    }
}

public struct MosaicTransition: Transition {
    let endX: Int
    let endY: Int
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            MosaicModifier(
                progress: phase.isIdentity ? 1 : 0,
                endX: endX,
                endY: endY
            )
        )
    }
}

// MARK: - Effect
struct MosaicModifier: ViewModifier {
    let progress: Double
    let endX: Int
    let endY: Int
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.mosaic(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(Float(endX)),
                            .float(Float(endY))
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
