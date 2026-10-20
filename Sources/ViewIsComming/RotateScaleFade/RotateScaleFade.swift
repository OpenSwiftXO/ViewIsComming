import SwiftUI

// MARK: - Transition
public extension Transition where Self == RotateScaleFadeTransition {
    static func rotateScaleFade(
        center: CGPoint = CGPoint(x: 0.5, y: 0.5),
        rotations: Double = 1.0,
        scale: Double = 8.0
    ) -> Self {
        RotateScaleFadeTransition(
            center: center,
            rotations: rotations,
            scale: scale
        )
    }
}

public struct RotateScaleFadeTransition: Transition {
    let center: CGPoint
    let rotations: Double
    let scale: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            RotateScaleFadeModifier(
                progress: phase.isIdentity ? 1 : 0,
                center: center,
                rotations: rotations,
                scale: scale
            )
        )
    }
}

// MARK: - Effect
struct RotateScaleFadeModifier: ViewModifier {
    let progress: Double
    let center: CGPoint
    let rotations: Double
    let scale: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.rotateScaleFade(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float2(Float(center.x), Float(center.y)),
                            .float(rotations),
                            .float(scale)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
