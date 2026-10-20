import SwiftUI

// MARK: - Transition
public extension Transition where Self == DoomScreenTransition {
    static func doomScreen(
        bars: Int = 30,
        amplitude: Double = 2.0,
        noise: Double = 0.1,
        frequency: Double = 0.5,
        dripScale: Double = 0.5
    ) -> Self {
        DoomScreenTransition(
            bars: bars,
            amplitude: amplitude,
            noise: noise,
            frequency: frequency,
            dripScale: dripScale
        )
    }
}

public struct DoomScreenTransition: Transition {
    let bars: Int
    let amplitude: Double
    let noise: Double
    let frequency: Double
    let dripScale: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            DoomScreenModifier(
                progress: phase.isIdentity ? 1 : 0,
                bars: bars,
                amplitude: amplitude,
                noise: noise,
                frequency: frequency,
                dripScale: dripScale
            )
        )
    }
}

// MARK: - Effect
struct DoomScreenModifier: ViewModifier {
    let progress: Double
    let bars: Int
    let amplitude: Double
    let noise: Double
    let frequency: Double
    let dripScale: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.doomScreen(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(Float(bars)),
                            .float(amplitude),
                            .float(noise),
                            .float(frequency),
                            .float(dripScale)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(x: 0, y: 1)
                    )
            }
    }
}
