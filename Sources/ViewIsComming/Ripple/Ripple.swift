import SwiftUI

// MARK: - Transition
public extension Transition where Self == RippleTransition {
    /// Ripple distortion transition emanating from center
    /// - Parameters:
    ///   - amplitude: Wave amplitude (default: 100.0)
    ///   - speed: Wave speed (default: 50.0)
    static func ripple(amplitude: Double = 100.0, speed: Double = 50.0) -> Self {
        RippleTransition(amplitude: amplitude, speed: speed)
    }
}

public struct RippleTransition: Transition {
    let amplitude: Double
    let speed: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            RippleModifier(
                progress: phase.isIdentity ? 1 : 0,
                amplitude: amplitude,
                speed: speed
            )
        )
    }
}

// MARK: - Effect
struct RippleModifier: ViewModifier {
    let progress: Double
    let amplitude: Double
    let speed: Double
    
    func body(content: Content) -> some View {
        content.visualEffect { content, geometryProxy in
            content.layerEffect(
                ViewIsCommingShaderLibrary.ripple(
                    .float2(geometryProxy.size),
                    .float(progress),
                    .float(amplitude),
                    .float(speed)
                ),
                maxSampleOffset: geometryProxy.size.scaled(0.05)
            )
        }
    }
}
