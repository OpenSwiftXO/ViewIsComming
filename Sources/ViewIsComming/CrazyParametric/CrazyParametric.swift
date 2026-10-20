import SwiftUI

// MARK: - Transition
public extension Transition where Self == CrazyParametricTransition {
    static func crazyParametric(
        outerRadius: Double = 4,
        innerRadius: Double = 1,
        waveIntensity: Double = 120,
        waveSmooth: Double = 0.1
    ) -> Self {
        CrazyParametricTransition(
            outerRadius: outerRadius,
            innerRadius: innerRadius,
            waveIntensity: waveIntensity,
            waveSmooth: waveSmooth
        )
    }
}

public struct CrazyParametricTransition: Transition {
    let outerRadius: Double
    let innerRadius: Double
    let waveIntensity: Double
    let waveSmooth: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            CrazyParametricModifier(
                progress: phase.isIdentity ? 1 : 0,
                outerRadius: outerRadius,
                innerRadius: innerRadius,
                waveIntensity: waveIntensity,
                waveSmooth: waveSmooth
            )
        )
    }
}

// MARK: - Effect
struct CrazyParametricModifier: ViewModifier {
    let progress: Double
    let outerRadius: Double
    let innerRadius: Double
    let waveIntensity: Double
    let waveSmooth: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.crazyParametric(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(outerRadius),
                            .float(innerRadius),
                            .float(waveIntensity),
                            .float(waveSmooth)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
