import SwiftUI

// MARK: - Transition
public extension Transition where Self == BurnTransition {
    static func burn(color: Color) -> Self {
        BurnTransition(color: color)
    }
}

public struct BurnTransition: Transition {
    let color: Color
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            BurnModifier(
                progress: phase.isIdentity ? 1 : 0,
                color: color
            )
        )
    }
}

// MARK: - Effect
struct BurnModifier: ViewModifier {
    @Environment(\.self) private var environment

    let progress: Double
    let color: Color
    
    func body(content: Content) -> some View {
        let resolved = color.resolve(in: environment)
        return content.visualEffect { content, geometryProxy in
            content.layerEffect(
                ViewIsCommingShaderLibrary.burn(
                    .float2(geometryProxy.size),
                    .float(progress),
                    .float3(Float(resolved.red), Float(resolved.green), Float(resolved.blue))
                ),
                maxSampleOffset: .zero
            )
        }
    }
}
