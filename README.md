# ViewIsComming

**ViewIsComming** is a Swift Package Manager (SPM) library engineered to significantly expand SwiftUI's transition capabilities.
It provides a rich collection of powerful, custom `Transition` effects, empowering developers to easily implement smooth, unique,
and complex entrance and exit animations for their Views.

> **Inspired by**: Transition effects are inspired and adapted from [GL Transitions](https://gl-transitions.com/) -
> a collection of GLSL transitions, reimplemented for SwiftUI using Metal shaders.

---

## ✨ Features

* **Extended Transitions Library**: Introduces a comprehensive library of professional, predefined `Transition` types
that go beyond the default options offered by SwiftUI.
* **Complex, Ready-to-Use Effects**: Offers sophisticated transition effects (such as flips, rotations, arc slides, etc.)
that can be applied with a single line of code.
* **Seamless SwiftUI Integration**: New transitions fully conform to the `Transition` protocol, ensuring perfect
and immediate integration with SwiftUI's native `transition(_:)` modifier.
* **Customizable & Composable**: Effects can be easily parameterized and combined (composited) to create highly unique
and custom transition experiences.

---

## 📋 Requirements

| Platform      | Minimum |
| ------------- | ------- |
| iOS           | 17.0    |
| macOS         | 14.0    |
| Mac Catalyst  | 17.0    |
| tvOS          | 17.0    |
| visionOS      | 2.0     |

watchOS is not supported: SwiftUI's Metal shader API is not available there.

---

## 📦 Installation

Add **ViewIsComming** to your project using **Swift Package Manager (SPM)**:

1.  In Xcode, navigate to **File > Add Packages...**
2.  Paste the repository URL into the search bar: `https://github.com/OpenSwiftXO/ViewIsComming`
3.  Select the desired version or branch.

Alternatively, add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/OpenSwiftXO/ViewIsComming", exact: "0.2.0")
]
```

---

## 🚀 Usage

Import the package and pass an effect to the `transition(_:)` modifier. The transition plays whenever the view is
inserted into or removed from the view hierarchy inside an animation:

```swift
import SwiftUI
import ViewIsComming

struct ContentView: View {
    @State private var showView = true

    var body: some View {
        VStack {
            if showView {
                Image(.photo)
                    .resizable()
                    .transition(.pixelize(squaresMin: 20))
            }

            Button("Toggle") {
                withAnimation(.easeInOut(duration: 1.5)) {
                    showView.toggle()
                }
            }
        }
    }
}
```

Use `.asymmetric(insertion:removal:)` to play a different effect (or the same effect in the opposite direction)
when the view leaves:

```swift
.transition(
    .asymmetric(
        insertion: .cube(rotateRight: true),
        removal: .cube(rotateRight: false)
    )
)
```

For detailed usage examples and demonstrations of all available transitions, with live controls for every
parameter, please refer to the **Demo app** included in the `Example` folder.

### How the effects work

GL Transitions blend between two images (*from* and *to*). A SwiftUI transition only ever sees one view, so every
effect is the *to* side of its GLSL original (or, for effects that only distort the outgoing image, that branch
played in reverse). Each shader follows the same contract:

* at `progress = 0` nothing of the view is visible,
* at `progress = 1` the view is rendered exactly as it is – the shader returns the layer untouched, so a view
  at rest costs nothing extra,
* SwiftUI plays the same effect backwards when the view is removed.

<details>
<summary>Available transitions</summary>

Angular, BookFlip, Bounce, BowTie, Burn, ButterflyWaveScrawler, CircleCrop, CornerVanish, CrazyParametric,
CrossHatch, CrossZoom, Cube, Directional, DirectionalWipe, DoomScreen, Doorway, Dreamy, DreamyZoom, Fade,
FadeColor, FadeGrayscale, Flip, FlyEye, Fold, GlitchDisplace, GlitchMemories, GridFlip, Heart, Hexagonalize,
InvertedPageCurl, Kaleidoscope, LinearBlur, Luma, LuminanceMelt, Morph, Mosaic, MultiplyBlend, Perlin, PinWheel,
Pixelize, PolarFunction, PolkaDotsCurtain, PowerKaleido, Radial, RandomNoise, RandomSquares, Rectangle, Ripple,
RotateScaleFade, SimpleBookCurl, SimpleZoom, Slide, Split, SquaresWire, Squeeze, StaticFade, StaticWipe,
StereoViewer, Swap, Swirl, TVStatic, UndulatingBurnOut, WaterDrop, Wave, Wind, WindowBlinds, WindowSlice

</details>

---

## 🧪 Development

Every transition lives in `Sources/ViewIsComming/<Name>/` as a Metal shader (`<Name>.metal`) plus its SwiftUI
wrapper (`<Name>.swift`), with a demo in `Example/Example/Demo/<Name>View.swift`.

```sh
swift test
```

The tests check that every shader is compiled into the library and called with the right arguments, and render
every transition at progress 0 and 1 to make sure it starts hidden and ends as the untouched view. New
transitions need an entry in `Tests/ViewIsCommingTests/TransitionCases.swift`.

---

## 📄 License

ViewIsComming is available under the MIT license. See [LICENSE](LICENSE). The transition algorithms are adapted
from [gl-transitions](https://github.com/gl-transitions/gl-transitions) (MIT).
