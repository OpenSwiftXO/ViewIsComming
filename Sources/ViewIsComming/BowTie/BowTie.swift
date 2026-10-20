import SwiftUI

public enum BowTieOrientation: Sendable {
    case horizontal
    case vertical
}

// MARK: - Transition
public extension Transition where Self == BowTieTransition {
    static func bowTie(
        orientation: BowTieOrientation = .horizontal
    ) -> Self {
        BowTieTransition(orientation: orientation)
    }
}

public struct BowTieTransition: Transition {
    let orientation: BowTieOrientation
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            BowTieModifier(
                progress: phase.isIdentity ? 1 : 0,
                orientation: orientation
            )
        )
    }
}

// MARK: - Effect
struct BowTieModifier: ViewModifier {
    let progress: Double
    let orientation: BowTieOrientation
    
    func body(content: Content) -> some View {
        let isHorizontal = orientation == .horizontal
        
        return content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        isHorizontal
                        ? ViewIsCommingShaderLibrary.bowTieHorizontal(
                            .float2(geometryProxy.size),
                            .float(progress)
                        )
                        : ViewIsCommingShaderLibrary.bowTieVertical(
                            .float2(geometryProxy.size),
                            .float(progress)
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
