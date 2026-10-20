import SwiftUI

@dynamicMemberLookup
enum ViewIsCommingShaderLibrary {
    /// The bundle that holds the compiled Metal library (`default.metallib`).
    static let bundle: Bundle = .module

    /// Created once: transition bodies are re-evaluated for every animation frame.
    private static let library = ShaderLibrary.bundle(bundle)

    static subscript(dynamicMember name: String) -> ShaderFunction {
        library[dynamicMember: name]
    }
}

extension CGSize {
    /// Upper bound, in points, for the `maxSampleOffset` an effect asks for on either axis.
    ///
    /// SwiftUI inflates the layer an effect samples from by `maxSampleOffset`. When that region grows too
    /// large the effect silently renders nothing and the view disappears: on iOS a 900 × 300 pt view
    /// vanished once the offset reached ~0.6 × its size, while 0.5 × was still fine. A modest cap keeps every
    /// view visible. The price is that content SwiftUI rasterises lazily (text, shapes – bitmaps are not
    /// affected) can be clipped when an effect samples further than this from the pixel it shades.
    static let maxSampleReach: CGFloat = 150

    /// The size scaled on both axes – the `maxSampleOffset` of an effect that reads up to
    /// `factor` of the view's size away from the pixel it shades, limited to `maxSampleReach`.
    func scaled(_ factor: Double) -> CGSize {
        scaled(x: factor, y: factor)
    }

    /// The size scaled per axis, for effects that only displace samples along one axis.
    func scaled(x: Double, y: Double) -> CGSize {
        CGSize(
            width: min(abs(width * x), Self.maxSampleReach),
            height: min(abs(height * y), Self.maxSampleReach)
        )
    }
}
