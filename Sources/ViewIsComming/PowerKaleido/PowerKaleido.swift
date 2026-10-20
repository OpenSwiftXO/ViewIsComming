import SwiftUI

// MARK: - Transition
public extension Transition where Self == PowerKaleidoTransition {
    /// A transition that creates a recursive-reflection kaleidoscope.
    ///
    /// - Parameters:
    ///   - scale: Overall zoom of the kaleidoscope pattern. Default is 2.0.
    ///   - z: Distortion depth. Default is 1.5.
    ///   - speed: Rotation speed. Default is 5.0.
    static func powerKaleido(
        scale: Double = 2.0,
        z: Double = 1.5,
        speed: Double = 5.0
    ) -> Self {
        PowerKaleidoTransition(scale: scale, z: z, speed: speed)
    }
}

public struct PowerKaleidoTransition: Transition {
    let scale: Double
    let z: Double
    let speed: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            PowerKaleidoModifier(
                progress: phase.isIdentity ? 1 : 0,
                scale: scale,
                z: z,
                speed: speed
            )
        )
    }
}

// MARK: - Effect
struct PowerKaleidoModifier: ViewModifier {
    let progress: Double
    let scale: Double
    let z: Double
    let speed: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.powerKaleido(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(scale),
                            .float(z),
                            .float(speed)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
