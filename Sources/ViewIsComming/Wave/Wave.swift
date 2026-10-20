import SwiftUI

// MARK: - Transition
public extension Transition where Self == WaveTransition {
    static func wave(
        amplitude: Double = 0.1,
        waves: Double = 5.0
    ) -> Self {
        WaveTransition(
            amplitude: amplitude,
            waves: waves
        )
    }
}

public struct WaveTransition: Transition {
    let amplitude: Double
    let waves: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            WaveModifier(
                progress: phase.isIdentity ? 1 : 0,
                amplitude: amplitude,
                waves: waves
            )
        )
    }
}

// MARK: - Effect
struct WaveModifier: ViewModifier {
    let progress: Double
    let amplitude: Double
    let waves: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.wave(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(amplitude),
                            .float(waves)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(x: abs(amplitude), y: 0)
                    )
            }
    }
}
