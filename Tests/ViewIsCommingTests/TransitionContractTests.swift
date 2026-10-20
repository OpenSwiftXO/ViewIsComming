import CoreGraphics
import Foundation
import Metal
import SwiftUI
import Testing
@testable import ViewIsComming

private let hasMetalDevice = MTLCreateSystemDefaultDevice() != nil

private let viewSize = CGSize(width: 120, height: 80)
private let backdrop = Color(white: 0.15)

/// A deterministic, fully opaque, non-uniform bitmap – the kind of content the
/// transitions are applied to in an app (photos).
private let testImage: CGImage = {
    let width = Int(viewSize.width)
    let height = Int(viewSize.height)
    let context = CGContext(
        data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    for y in 0..<height {
        for x in 0..<width {
            let checker = ((x / 10 + y / 10) % 2 == 0)
            context.setFillColor(
                red: CGFloat(x) / CGFloat(width),
                green: CGFloat(y) / CGFloat(height),
                blue: checker ? 0.95 : 0.25,
                alpha: 1
            )
            context.fill(CGRect(x: x, y: y, width: 1, height: 1))
        }
    }
    return context.makeImage()!
}()

@MainActor
private func render(_ content: some View) -> [UInt8]? {
    let renderer = ImageRenderer(
        content: ZStack {
            backdrop
            content
        }
        .frame(width: viewSize.width, height: viewSize.height)
    )
    renderer.scale = 1
    guard let image = renderer.cgImage else { return nil }

    var pixels = [UInt8](repeating: 0, count: image.width * image.height * 4)
    let context = CGContext(
        data: &pixels, width: image.width, height: image.height, bitsPerComponent: 8,
        bytesPerRow: image.width * 4, space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    return pixels
}

private func meanAbsoluteDifference(_ a: [UInt8], _ b: [UInt8]) -> Double {
    guard a.count == b.count, !a.isEmpty else { return .infinity }
    var total = 0
    for index in a.indices {
        total += abs(Int(a[index]) - Int(b[index]))
    }
    return Double(total) / Double(a.count)
}

/// Contract every transition has to honour so the view never pops at either end:
/// progress 0 leaves nothing of the view behind and progress 1 is the untouched view.
@Suite("Transition contract", .enabled(if: hasMetalDevice))
@MainActor
struct TransitionContractTests {
    private func card() -> AnyView {
        AnyView(
            Image(decorative: testImage, scale: 1)
                .resizable()
                .frame(width: viewSize.width, height: viewSize.height)
        )
    }

    @Test("Every shader transition has a contract case")
    func everyTransitionHasACase() throws {
        let sources = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/ViewIsComming")
        let directories = try FileManager.default.contentsOfDirectory(atPath: sources.path)
            .filter { directory in
                FileManager.default.fileExists(
                    atPath: sources.appendingPathComponent("\(directory)/\(directory).metal").path
                )
            }
        let cases = Set(transitionCases.map(\.name))
        for directory in directories {
            #expect(cases.contains(directory), "\(directory) is missing from transitionCases")
        }
        for name in cases {
            #expect(directories.contains(name), "transitionCases lists \(name), which has no shader")
        }
    }

    @Test("Progress 1 renders the untouched view")
    func restingStateIsTheOriginalView() throws {
        let reference = try #require(render(card()))
        for (name, apply) in transitionCases {
            let pixels = try #require(render(apply(card(), 1)), "\(name) did not render")
            let difference = meanAbsoluteDifference(pixels, reference)
            #expect(difference < 1.5, "\(name) at progress 1 differs from the view by \(difference)")
        }
    }

    @Test("Progress 0 hides the view")
    func activeStateIsHidden() throws {
        let background = try #require(render(Color.clear))
        for (name, apply) in transitionCases {
            let pixels = try #require(render(apply(card(), 0)), "\(name) did not render")
            let difference = meanAbsoluteDifference(pixels, background)
            #expect(difference < 2.5, "\(name) at progress 0 still shows the view (\(difference))")
        }
    }
}
