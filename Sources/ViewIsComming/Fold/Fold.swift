import SwiftUI

// MARK: - Transition
public extension Transition where Self == FoldTransition {
    /// A transition that creates a folding paper effect.
    ///
    /// - Parameters:
    ///   - folds: Number of folds (1 to 10). Default is 3.
    ///   - intensity: Fold intensity (0.0 to 1.0). Default is 0.5.
    /// - Returns: A transition that creates a folding effect.
    static func fold(
        folds: Double = 3.0,
        intensity: Double = 0.5
    ) -> Self {
        FoldTransition(
            folds: folds,
            intensity: intensity
        )
    }
}

public struct FoldTransition: Transition {
    let folds: Double
    let intensity: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            FoldModifier(
                progress: phase.isIdentity ? 1 : 0,
                folds: folds,
                intensity: intensity
            )
        )
    }
}

// MARK: - Effect
struct FoldModifier: ViewModifier {
    let progress: Double
    let folds: Double
    let intensity: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.fold(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(folds),
                            .float(intensity)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
