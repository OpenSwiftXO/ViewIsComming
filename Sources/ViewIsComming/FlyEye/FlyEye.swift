import SwiftUI

// MARK: - Transition
public extension Transition where Self == FlyEyeTransition {
    static func flyEye(
        size: Double = 0.04,
        zoom: Double = 50.0,
        colorSeparation: Double = 0.3
    ) -> Self {
        FlyEyeTransition(
            size: size,
            zoom: zoom,
            colorSeparation: colorSeparation
        )
    }
}

public struct FlyEyeTransition: Transition {
    let size: Double
    let zoom: Double
    let colorSeparation: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            FlyEyeModifier(
                progress: phase.isIdentity ? 1 : 0,
                size: size,
                zoom: zoom,
                colorSeparation: colorSeparation
            )
        )
    }
}

// MARK: - Effect
struct FlyEyeModifier: ViewModifier {
    let progress: Double
    let size: Double
    let zoom: Double
    let colorSeparation: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.flyEye(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(size),
                            .float(zoom),
                            .float(colorSeparation)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(abs(size))
                    )
            }
    }
}
