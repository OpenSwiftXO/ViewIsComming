import SwiftUI

// MARK: - Transition
public extension Transition where Self == NoneTransition {
    static var none: Self {
        NoneTransition()
    }
}

public struct NoneTransition: Transition {
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .background {
                EmptyView()
                    .opacity(phase.isIdentity ? 1 : 0)
            }
    }
}
