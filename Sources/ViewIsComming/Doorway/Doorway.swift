import SwiftUI

// MARK: - Transition
public extension Transition where Self == AsymmetricTransition<DoorwayTransition, DoorwayTransition> {
    /// The view zooms in over a reflective floor and splits open like a door when it is removed.
    /// - Parameters:
    ///   - reflection: Strength of the reflection (default: 0.4)
    ///   - perspective: Perspective of the opening doors (default: 0.4)
    ///   - depth: How far the view starts away from the viewer (default: 3.0)
    static func doorway(
        reflection: Double = 0.4,
        perspective: Double = 0.4,
        depth: Double = 3.0
    ) -> Self {
        AsymmetricTransition(
            insertion: DoorwayTransition(
                depth: depth,
                perspective: perspective,
                reflection: reflection,
                isInsertion: true
            ),
            removal: DoorwayTransition(
                depth: depth,
                perspective: perspective,
                reflection: reflection,
                isInsertion: false
            )
        )
    }
}

public extension Transition where Self == DoorwayTransition {
    /// Only the insertion half of `doorway(reflection:perspective:depth:)`.
    static func doorwayIn(
        reflection: Double = 0.4,
        perspective: Double = 0.4,
        depth: Double = 3.0
    ) -> Self {
        DoorwayTransition(
            depth: depth,
            perspective: perspective,
            reflection: reflection,
            isInsertion: true
        )
    }
    
    /// Only the removal half of `doorway(reflection:perspective:depth:)`.
    static func doorwayOut(
        reflection: Double = 0.4,
        perspective: Double = 0.4,
        depth: Double = 3.0
    ) -> Self {
        DoorwayTransition(
            depth: depth,
            perspective: perspective,
            reflection: reflection,
            isInsertion: false
        )
    }
}

public struct DoorwayTransition: Transition {
    let depth: Double
    let perspective: Double
    let reflection: Double
    let isInsertion: Bool
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        // Insertion plays towards progress 1, removal towards progress 0.
        let visible = isInsertion ? 1.0 : 0.0
        return content.modifier(
            DoorwayModifier(
                progress: phase.isIdentity ? visible : 1.0 - visible,
                depth: depth,
                perspective: perspective,
                reflection: reflection,
                isInsertion: isInsertion
            )
        )
    }
}

// MARK: - Effect
struct DoorwayModifier: ViewModifier {
    let progress: Double
    let depth: Double
    let perspective: Double
    let reflection: Double
    let isInsertion: Bool
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.doorway(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(depth),
                            .float(perspective),
                            .float(reflection),
                            .float(isInsertion ? 1.0 : 0.0)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
