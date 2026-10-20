import SwiftUI

// MARK: - Transition
public extension Transition where Self == FadeTransition {
    /// Simple cross-fade transition
    /// Directly fades between two views using opacity
    static var fade: Self {
        FadeTransition()
    }
}

public struct FadeTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .opacity(phase.isIdentity ? 1 : 0)
    }
}
