import SwiftUI

// MARK: - Transition
public extension Transition {
    /// Plays `insertion` when the view appears and `removal` when it disappears.
    ///
    /// Shorthand for `AsymmetricTransition(insertion:removal:)` that reads like the
    /// other transitions: `.transition(.asymmetric(insertion: .cube(), removal: .fade))`.
    static func asymmetric<Insertion: Transition, Removal: Transition>(
        insertion: Insertion,
        removal: Removal
    ) -> Self where Self == AsymmetricTransition<Insertion, Removal> {
        AsymmetricTransition(insertion: insertion, removal: removal)
    }
}
