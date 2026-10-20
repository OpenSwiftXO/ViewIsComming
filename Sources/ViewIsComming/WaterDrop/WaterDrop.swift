import SwiftUI

// MARK: - Transition
public extension Transition where Self == WaterDropTransition {
    /// A transition that creates a water drop distortion effect emanating from the center
    /// - Parameters:
    ///   - amplitude: The strength of the distortion (default: 0.04)
    ///   - speed: The frequency of the oscillation (default: 20.0)
    /// - Returns: A custom transition with water drop distortion
    static func waterDrop(
        amplitude: Double = 0.04,
        speed: Double = 20.0
    ) -> Self {
        WaterDropTransition(
            amplitude: amplitude,
            speed: speed
        )
    }
}

public struct WaterDropTransition: Transition {
    let amplitude: Double
    let speed: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            WaterDropModifier(
                progress: phase.isIdentity ? 1 : 0,
                amplitude: amplitude,
                speed: speed
            )
        )
    }
}

// MARK: - Effect
struct WaterDropModifier: ViewModifier {
    let progress: Double
    let amplitude: Double
    let speed: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.waterDrop(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(amplitude),
                            .float(speed)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(0.03)
                    )
            }
    }
}
