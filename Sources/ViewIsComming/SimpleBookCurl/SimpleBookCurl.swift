import SwiftUI

// MARK: - Transition
public extension Transition where Self == SimpleBookCurlTransition {
    /// A transition that creates a simple book page curl effect.
    ///
    /// - Parameters:
    ///   - curlAmount: Amount of curl shadow (0.0 to 1.0). Default is 0.5.
    ///   - radius: Curl radius (0.0 to 1.0). Default is 0.2.
    /// - Returns: A transition that creates a book curl effect.
    static func simpleBookCurl(
        curlAmount: Double = 0.5,
        radius: Double = 0.2
    ) -> Self {
        SimpleBookCurlTransition(
            curlAmount: curlAmount,
            radius: radius
        )
    }
}

public struct SimpleBookCurlTransition: Transition {
    let curlAmount: Double
    let radius: Double
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            SimpleBookCurlModifier(
                progress: phase.isIdentity ? 1 : 0,
                curlAmount: curlAmount,
                radius: radius
            )
        )
    }
}

// MARK: - Effect
struct SimpleBookCurlModifier: ViewModifier {
    let progress: Double
    let curlAmount: Double
    let radius: Double
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.simpleBookCurl(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(curlAmount),
                            .float(radius)
                        ),
                        maxSampleOffset: geometryProxy.size.scaled(1)
                    )
            }
    }
}
