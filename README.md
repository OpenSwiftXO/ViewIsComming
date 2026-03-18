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

## 📦 Installation

Add **ViewIsComming** to your project using **Swift Package Manager (SPM)**:

1.  In Xcode, navigate to **File > Add Packages...**
2.  Paste the repository URL into the search bar: `https://github.com/OpenSwiftXO/ViewIsComming`
3.  Select the desired version or branch.

Alternatively, add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/OpenSwiftXO/ViewIsComming", .exact("0.2.0"))
]
```

---

## 🚀 Usage

For detailed usage examples and demonstrations of all available transitions,
please refer to the **Demo app** included in the `Example` folder.
