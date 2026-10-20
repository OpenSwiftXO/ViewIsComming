import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Angular") { AngularView() }
                NavigationLink("BookFlip") { BookFlipView() }
                NavigationLink("Bounce") { BounceView() }
                NavigationLink("BowTie") { BowTieView() }
                NavigationLink("Burn") { BurnView() }
                NavigationLink("ButterflyWaveScrawler") { ButterflyWaveScrawlerView() }
                NavigationLink("CircleCrop") { CircleCropView() }
                NavigationLink("CornerVanish") { CornerVanishView() }
                NavigationLink("CrazyParametric") { CrazyParametricView() }
                NavigationLink("CrossHatch") { CrossHatchView() }
                NavigationLink("CrossZoom") { CrossZoomView() }
                NavigationLink("Cube") { CubeView() }
                NavigationLink("Directional") { DirectionalView() }
                NavigationLink("DirectionalWipe") { DirectionalWipeView() }
                NavigationLink("DoomScreen") { DoomScreenView() }
                NavigationLink("Doorway") { DoorwayView() }
                NavigationLink("Dreamy") { DreamyView() }
                NavigationLink("Dreamy Zoom") { DreamyZoomView() }
                NavigationLink("Fade") { FadeView() }
                NavigationLink("Fade Color") { FadeColorView() }
                NavigationLink("Fade Grayscale") { FadeGrayscaleView() }
                NavigationLink("Flip") { FlipView() }
                NavigationLink("Fly Eye") { FlyEyeView() }
                NavigationLink("Fold") { FoldView() }
                NavigationLink("Glitch Displace") { GlitchDisplaceView() }
                NavigationLink("GlitchMemories") { GlitchMemoriesView() }
                NavigationLink("Grid Flip") { GridFlipView() }
                NavigationLink("Heart") { HeartView() }
                NavigationLink("Hexagonalize") { HexagonalizeView() }
                NavigationLink("InvertedPageCurl") { InvertedPageCurlView() }
                NavigationLink("Kaleidoscope") { KaleidoscopeView() }
                NavigationLink("Linear Blur") { LinearBlurView() }
                NavigationLink("Luma") { LumaView() }
                NavigationLink("Luminance Melt") { LuminanceMeltView() }
                NavigationLink("Morph") { MorphView() }
                NavigationLink("Mosaic") { MosaicView() }
                NavigationLink("Multiply Blend") { MultiplyBlendView() }
                NavigationLink("Perlin") { PerlinView() }
                NavigationLink("PinWheel") { PinWheelView() }
                NavigationLink("Pixelize") { PixelizeView() }
                NavigationLink("Polar Function") { PolarFunctionView() }
                NavigationLink("PolkaDotsCurtain") { PolkaDotsCurtainView() }
                NavigationLink("Power Kaleido") { PowerKaleidoView() }
                NavigationLink("Radial") { RadialView() }
                NavigationLink("RandomNoise") { RandomNoiseView() }
                NavigationLink("RandomSquares") { RandomSquaresView() }
                NavigationLink("Rectangle") { RectangleView() }
                NavigationLink("Ripple") { RippleView() }
                NavigationLink("Rotate Scale Fade") { RotateScaleFadeView() }
                NavigationLink("Simple Book Curl") { SimpleBookCurlView() }
                NavigationLink("Simple Zoom") { SimpleZoomView() }
                NavigationLink("Slide") { SlideView() }
                NavigationLink("Split") { SplitView() }
                NavigationLink("SquaresWire") { SquaresWireView() }
                NavigationLink("Squeeze") { SqueezeView() }
                NavigationLink("Static Fade") { StaticFadeView() }
                NavigationLink("Static Wipe") { StaticWipeView() }
                NavigationLink("StereoViewer") { StereoViewerView() }
                NavigationLink("Swap") { SwapView() }
                NavigationLink("Swirl") { SwirlView() }
                NavigationLink("TV Static") { TVStaticView() }
                NavigationLink("UndulatingBurnOut") { UndulatingBurnOutView() }
                NavigationLink("Water Drop") { WaterDropView() }
                NavigationLink("Wave") { WaveView() }
                NavigationLink("Wind") { WindView() }
                NavigationLink("WindowBlinds") { WindowBlindsView() }
                NavigationLink("WindowSlice") { WindowSliceView() }
            }
            .navigationTitle("View Is Comming")
        }
    }
}

#Preview {
    ContentView()
}
