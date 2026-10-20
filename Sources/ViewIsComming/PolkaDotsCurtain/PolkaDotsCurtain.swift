import SwiftUI

public enum PolkaDotsCurtainCenter {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case center
    case custom(x: Double, y: Double)
    
    var point: CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: 0.0, y: 0.0)
        case .topRight:
            return CGPoint(x: 1.0, y: 0.0)
        case .bottomLeft:
            return CGPoint(x: 0.0, y: 1.0)
        case .bottomRight:
            return CGPoint(x: 1.0, y: 1.0)
        case .center:
            return CGPoint(x: 0.5, y: 0.5)
        case .custom(let x, let y):
            let clampedX = max(0.0, min(1.0, x))
            let clampedY = max(0.0, min(1.0, y))
            return CGPoint(x: clampedX, y: clampedY)
        }
    }
}

// MARK: - Transition
public extension Transition where Self == PolkaDotsCurtainTransition {
    static func polkaDotsCurtain(
        dots: Double = 20.0,
        center: PolkaDotsCurtainCenter = .center
    ) -> Self {
        PolkaDotsCurtainTransition(dots: dots, center: center.point)
    }
}

public struct PolkaDotsCurtainTransition: Transition {
    let dots: Double
    let center: CGPoint
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content.modifier(
            PolkaDotsCurtainModifier(
                progress: phase.isIdentity ? 1 : 0,
                dots: dots,
                center: center
            )
        )
    }
}

// MARK: - Effect
struct PolkaDotsCurtainModifier: ViewModifier {
    let progress: Double
    let dots: Double
    let center: CGPoint
    
    func body(content: Content) -> some View {
        content
            .visualEffect { content, geometryProxy in
                content
                    .layerEffect(
                        ViewIsCommingShaderLibrary.polkaDotsCurtain(
                            .float2(geometryProxy.size),
                            .float(progress),
                            .float(dots),
                            .float2(Float(center.x), Float(center.y))
                        ),
                        maxSampleOffset: .zero
                    )
            }
    }
}
